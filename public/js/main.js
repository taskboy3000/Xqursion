// Xcursion common routines and initialization

// FIXME - move to controller/action.js
function delete_step () {
  var url = $(this).attr("data-url");
  $.ajax({
        url: url,
        method: "DELETE",
        dataType: "html",
        success: function(d) { 
           window.location.reload();
        },        
        });
}

function initialize_confirmations () {
    $("[data-toggle=confirmation]").confirmation({
        btnOkIcon: "glyphicon glyphicon-ok-circle",
        btnCancelIcon: "glyphicon glyphicon-remove-circle",
        singleton: false,
        popout: false,
    });
}

// This function initializes a table to enable simple, alpha-sorting
// based on column position
function initialize_sortable_table(this_table)
{
    $(this_table).find("th[role=sorter]").each(function() {
        var link = document.createElement("a");
        $(link)
            .attr("href", "#")
            .attr("data-toggle", "sort")
            .attr("data-column", $(this).index())
            .attr("data-order", "a");

        $(link).append($(this).text());

        var icon = document.createElement("i");
        $(icon).addClass("glyphicon").addClass("glyphicon-sort").addClass("sort-icon");
        $(link).append(icon);

        $(this).empty().append(link);
    });

    $(this_table).find("[data-toggle=sort]").off("click").on("click", function(e)
                                                       {
                                                           e.preventDefault();
                                                           sort_table(this_table, $(this).attr("data-column"), $(this).attr("data-order"));
                                                           // invert the sort order for the next invocation
                                                           $(this).attr("data-order",
                                                                        ($(this).attr("data-order") == "a"
                                                                        ? "d"
                                                                        : "a")
                                                                       );
                                                       });
}

// This function does the actual table sorting
function sort_table (this_table, sort_column_index, sort_order)
{
    // get all the rows
    var rows = $(this_table).find("tbody > tr");
    //console.log(rows);

    // sort them appropriately
    if (sort_order == "a")
    {
        // Ascending alpha sort by the given column
        rows.sort(function(a,b) {
            var a_text = $($(a).find("td")[sort_column_index]).text().toUpperCase(); // please, no HTML
            var b_text = $($(b).find("td")[sort_column_index]).text().toUpperCase(); // please, no HTML
            // console.log("Comparing '" + a + "' to '" + b + "'");

            if (a_text > b_text) {
                return 1;
            } else if (b_text > a_text) {
                return -1;
            } else {
                return 0;
            }
        });
     } else {
        // Descending alpha sort by the given column
        rows.sort(function(a,b) {
            var a_text = $($(a).find("td")[sort_column_index]).text().toUpperCase(); // please, no HTML
            var b_text = $($(b).find("td")[sort_column_index]).text().toUpperCase(); // please, no HTML
            // console.log("Comparing '" + a + "' to '" + b + "'");

            if (b_text > a_text) {
                return 1;
            } else if (a_text > b_text) {
                return -1;
            } else {
                return 0;
            }
        });
     }

    // empty the target table tbody and replace with sorted rows
    $(this_table).find("tbody").empty().append(rows);
}

$(document).ready(function() {
/*
  $("[data-provide=datepicker]").datepicker({
        format: "yyyy-mm-dd",
  });
*/

  $("table[role=sortable]").each(function(){ initialize_sortable_table(this); });
  initialize_confirmations();
});