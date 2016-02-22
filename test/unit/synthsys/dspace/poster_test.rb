require 'test_helper'

class PosterTest < ActiveSupport::TestCase

  def setup
    @poster = Synthsys::Dspace::Poster.new
  end

  def teardown
    # Do nothing
  end

=begin
  def test_handles_wrong_addr

    url = "http://turnip1.bio.ed.ac.uk:8550/deposit"
    payload = '{"collection":"Sword","title":"First package","description":"AT0089 data sets from R+L experiment.\\nOne day seedlings in different photoperiods","funder":"BBSRC","depositor":"Tomasz","publisher":"University of Edinburgh. School of Biology","creators":"Tomasz Zielinski, Andrew Millar","keywords":"clock, arabidopsis","subject":"Circadian experiment","toc":"ATxxx files contain raw data.\\n pedro.xml metadata description","licence":"Creative Commons Attribution 4.0 International licence","type":"Dataset","filePath":"/localdisk/seek/investigation-11-2.ro.zip","fileName":"investigation-11-2.ro.zip","fileType":"application/zip"}'

    resp = @poster.post(url,payload)
    puts resp.class
    puts resp.body
    puts resp


  end
=end

end