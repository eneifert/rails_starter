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
//= require jquery-ui.min
//= require jquery_ujs
//= require bootstrap-select.min
//= require turbolinks
//= require jquery.pjax
//= require bootstrap.min
//= require mustache.min
//= require moment
//= require moment/ru
//= require bootstrap-datetimepicker
//= require select2.full.min
//= require select2_ru
//= require jquery.maskedinput.min
//= require jquery.form.min
//= require_tree .

var pjax_setup;
var pjax_form_submitted;
pjax_setup = function(){

	if( $('#pjax-container').length < 1){
		return;
	}

	$(document).pjax("a:not([data-remote]):not([data-behavior]):not([data-skip-pjax]):not([data-method='delete']):not([target='_blank'])", '#pjax-container', {timeout: 1500})	
	$(document)

		.on('pjax:beforeSend', function(){			
			$('body').addClass("pjax-loading")					
		})
		.on('pjax:error', function(xhr, textStatus, error, options){
			var s = "stop";
			if (pjax_form_submitted != null){
				pjax_form_submitted.data('skip-pjax', true);
				pjax_form_submitted.submit();
			}
			// $(this).parents('form').submit();
		})
		.off('pjax:success').on('pjax:success', function(){
			$('body').removeClass("pjax-loading")
		})
		.on('pjax:end', function(){		
			pjax_form_submitted = null;
			if(typeof app_ready !== 'undefined') {
				app_ready();
			}			
			if(typeof ready !== 'undefined') {
				ready();
			}			
			
		})
		.on('submit', 'form', function(event) {

			if($(this).data('skip-pjax')){
				return;
			}
			
			pjax_form_submitted = $(this);
		    event.preventDefault(); // stop default submit behavior

		    $.pjax.submit(event, '#pjax-container');
		});
	// $(document).on('submit', 'form[data-pjax]', function(event) {
	//   $.pjax.submit(event, '#pjax-container')
	// })
}

var app_ready;
app_ready = function() {

	moment.locale('en', {
	  week: { dow: 1 } // Monday is the first day of the week
	});

	function checkEnter(e){
	 e = e || event;
	 var txtArea = /textarea/i.test((e.target || e.srcElement).tagName);
	 return txtArea || (e.keyCode || e.which || e.charCode || 0) !== 13;
	}

	try {
	    // disable enter for form submitions
		document.querySelector('form').onkeypress = checkEnter;
	}
	catch(err) {	    
	}
	

	$('#side-menu li a').removeClass('nav-highlighted');
	$("#side-menu li a[href='{0}']".format(window.location.pathname)).addClass('nav-highlighted');

	 

	$('table').stickyTableHeaders();

	// start the notifications poller
	// NotificationPoller.request();	    
		
	//This helps the select picker to honor the data-selected attribute
	$('.selectpicker:not(.selectpicker-initialized)').each(function(index){

	 	var selected = $(this).data('selected');
	 	if(selected != undefined){
	 		$(this).val(selected.toString().split(',')); 		 			 		
	 		$(this).selectpicker('render');	 			 	
	 	}
	 	else
	 		$(this).selectpicker();
	 	 	 
	 	$(this).addClass("selectpicker-initialized");
	 });

	// 
	// Image preview and deletion meant to be used with <%= render :partial => 'elements/image_upload_element', :locals => {f: f, :key => 'logo'.to_sym, file: @user.logo, img_classes: "business-logo" } %>                      
	// 
    function readURL(input, id) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#' + id + ' img').attr('src', e.target.result);
            }
            reader.readAsDataURL(input.files[0]);
        }
    }
	$(".image-upload-field").change(function(){
        readURL(this, $(this).data('preview-id'));        
        $('#' + $(this).data('preview-id') + ' input').val(false);
        $('#'+ $(this).data('preview-id') + ' .delete-image').removeClass('hidden');  
        $(this).parents('form').attr('data-skip-pjax', 'true');      
    });


    $('.delete-image').click(function(){
      $(this).siblings('input').val(true);
      $(this).siblings('img')
        .attr('src', '/no_image.jpg')        
      $(this).addClass('hidden');

    });

	$('.phone-mask').mask("?+999-999-99-99-99");

	$('.datetimepicker').each(function(index){	

		var datetime_format = "";
		if ($(this).data('pick-date')) {
			
			// DO NOT CHANGE TO "MMM DD YYYY" RAILS has problems parsing the Russian Date in that format
				datetime_format += "DD MMM YYYY ";
			// DO NOT CHANGE TO "MMM DD YYYY" RAILS has problems parsing the Russian Date in that format
		}
		if ($(this).data('pick-time')){
			datetime_format += "HH:mm";
		}

		$(this).datetimepicker({                                                                                
                    sideBySide: $(this).data('pick-time') && $(this).data('pick-date'),
                    stepping: 15,
                    locale: $(this).data('locale'),
                    format: datetime_format,
                    useCurrent: true,
                    defaultDate: $(this).data('value') == "" ? null : moment($(this).data('value'), moment.ISO_8601),                                        
                    showClear: $(this).data('show-clear')
                })
	}).click(function(){
    	$(this).data("DateTimePicker").show()
    });

	$('.country-picker:not(.select2-initialized), .as-select2-picker:not(.select2-initialized), .product-picker:not(.select2-initialized)').each(function(index){
	 	
 		$(this).select2({
 			// allowClear: true  
 		});
	 	 	 
	 	$(this).addClass("select2-initialized");
	 });	


};

$(document).ready(app_ready);
$(document).on('page:load', app_ready);

$(document).ready(pjax_setup);
$(document).on('page:load', pjax_setup);


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