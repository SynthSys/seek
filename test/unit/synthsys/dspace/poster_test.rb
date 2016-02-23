require 'test_helper'

class PosterTest < ActiveSupport::TestCase

  def setup
    @poster = Synthsys::Dspace::Poster.new
  end

  def teardown
    # Do nothing
  end

  test "returns true for success with empty body" do

    content = 'A kuku matutu'
    url = 'http://localhost:8550/testservice'

    stub_request(:post, url).
        with(:body => content)

    resp = @poster.post(url,content)
    assert resp

    stub_request(:post, url).
        with(:body => content).
        to_return(:body => "")

    resp = @poster.post(url,content)
    assert resp

  end

  test "returns body content for success with a body" do

    content = 'A kuku matutu'
    url = 'http://localhost:8550/testservice'

    stub_request(:post, url).
        with(:body => content).
        to_return(:body => "ALA")

    resp = @poster.post(url,content)
    assert_equal "ALA", resp

  end

  test "raise PostError on http error" do

    content = 'A kuku matutu'
    url = 'http://localhost:8550/testservice'

    stub_request(:post, url).
        with(:body => content).
        to_return(:body => "NOO", :status => [400, 'Bad Request'])

    msg = "HTTP ERROR 400\nNOO"
    assert_raise_with_message(Synthsys::Dspace::Poster::PostError,msg) do
      resp = @poster.post(url,content)
    end

    stub_request(:post, url).
        with(:body => content).
        to_return(:status => [500, 'Server error'])

    msg = "HTTP ERROR 500\n"
    assert_raise_with_message(Synthsys::Dspace::Poster::PostError,msg) do
      resp = @poster.post(url,content)
    end
  end

  test "raise PostError on wrong url" do

    content = 'A kuku matutu'
    url = 'http://localhost12:8550/testservice'

    err = assert_raise(Synthsys::Dspace::Poster::PostError) do
      resp = @poster.post(url,content)
    end

    assert err.message.start_with?("Got exception:")

  end

  test "raise PostError on connection timeout" do

    content = 'A kuku matutu'
    url = 'http://localhost:8550/testservice'

    stub_request(:post, url).
        with(:body => content).
        to_timeout

    err = assert_raise(Synthsys::Dspace::Poster::PostError) do
      resp = @poster.post(url,content)
    end

    assert err.message.start_with?("Got exception:")

  end



end