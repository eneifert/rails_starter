// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-select.min
//= require turbolinks
//= require_tree .

var ready;
ready = function() {


	//This helps the select picker to honor the data-selected attribute
	$('.selectpicker').each(function(index){

	 	var selected = $(this).data('selected');
	 	if(selected != undefined){
	 		$(this).val(selected.toString().split(',')); 		 			 		
	 		$(this).selectpicker('render');	 			 	
	 	}
	 	else
	 		$(this).selectpicker();
	 	 	 
	 });
};

$(document).ready(ready);
$(document).on('page:load', ready);


// First, checks if it isn't implemented yet.
if (!String.prototype.format) {
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) { 
      return typeof args[number] != 'undefined'
        ? args[number]
        : match
      ;
    });
  };
}