jQuery(document).ready(function(){
    jQuery(document).on("exhibitConfigured.exhibit", function() {
        hideFacets();
        hide_specified_facet_list();
        displayMoreLink();
    });
});

function load_tabs() {
    var tabberOptions = {'onLoad':function() {

    }};
    tabberAutomatic(tabberOptions);
}

//this is for the case of multiple exhibit instance.
function tab_on_click(resource_type, resource_ids, with_facets) {
    var tab_content_id = 'faceted_search_result';
    var click_tab = document.getElementById('tab_' + resource_type);

    click_tab.onclick = function () {
        show_large_ajax_loader(tab_content_id);
        deactivate_previous_tab();
        click_tab.className = 'tabberactive';

        Exhibit.SelectionState.currentAssetType = resource_type;

        jQuery.noConflict();
        var $j = jQuery;
        if (with_facets == true){
            $j.ajax({
                url: items_for_facets_url,
                async: false,
                type: 'POST',
                data: { item_ids: resource_ids,
                    item_type: resource_type}
            })
                .done(function (data) {
                    var tab_content = $j('#' + tab_content_id);
                    tab_content.html(data.items_for_facets);
                });

        }else{
            $j.ajax({
                url: items_for_result_url,
                async: false,
                type: "POST",
                data: { items: generateParamItems(resource_type, resource_ids)}
            })
                .done(function (data) {
                    var tab_content = $j('#' + tab_content_id);
                    tab_content.html(data.items_for_result);
                });

        }
    }
}

//params items: e.g. Model_1,Model_2,...
function generateParamItems(resource_type, resource_ids){
    var items = resource_type + '_';
    items = items + resource_ids.replace(/,/g, ',' + resource_type + '_');
    return items;
}

//this is for the case of multiple exhibit instance.
function hideFacets(){
    $j('.exhibit-facet-header-collapse').map(function(){
        var grand_parent = this.parentNode.parentNode;
        var id = grand_parent.id;
        if (id != null && id.match('toogle_facet_') != null){
            grand_parent.hide();
        }
    })
}

function deactivate_previous_tab(){
    //First change the color of the previous chosen tab
    var previous_active_tab = document.getElementsByClassName('tabberactive')[0];
    if (previous_active_tab != null)
        previous_active_tab.className = '';
}

//this is for the case of one exhibit instance.
function tab_on_click_one_facet(resource_type) {
    var click_tab = document.getElementsByClassName(resource_type)[0];
    click_tab.onclick = function () {
        deactivate_previous_tab();
        //Hide all the tab content
        hide_all_tabs_content();
        //Hide more-facets for previous clicked tab
        hide_specified_facets();
        //Activate the clicking tab
        click_tab.parentElement.className = 'tabberactive';
        active_tab = resource_type;
        //Show the content of clicking tab
        $j('#' + resource_type).removeClass('tabbertabhide');

        show_specified_facets_for_active_tab(resource_type);
    }
}

function displayMoreLink(){
    $j(".more_link").show();
}

//this is for the case of one exhibit instance.
function hide_specified_facets(){
    $j(".specified_facets").hide();
}

//this is for the case of one exhibit instance.
function hide_specified_facet_list(){
    $j(".specified_facet_list").hide();
}

//this is for the case of one exhibit instance.
function hide_all_tabs_content(){
    var all_tabs_content = $j('.tabbertab');
    for (var i=0; i<all_tabs_content.length; i++){
        var tab = all_tabs_content[i];
        var class_name = tab.className;
        if (class_name.match('tabbertabhide') == null){
            tab.className = tab.className + ' tabbertabhide';
        }
    }
}

//this is for the case of one exhibit instance.
function show_specified_facets_for_active_tab(active_tab) {
    var more_facet_id = "specified_" + active_tab + "_facets";
    $j('#' + more_facet_id).show();
}