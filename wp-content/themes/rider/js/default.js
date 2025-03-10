
(function ($) {
    var index = 0;
    $.fn.menumaker = function (options) {
        var mainmenu = jQuery(this),
            settings = jQuery.extend({
                title: "",
                breakpoint: 1024,
                format: "dropdown",
                sticky: false
            }, options);
        return this.each(function () {
            mainmenu.prepend('<button id="menu-button" class="fa fa-bars" aria-hidden="true">' + settings.title + '</button>');
            jQuery(this).find("#menu-button").on('click', function () {
                jQuery(this).toggleClass('menu-opened');
                var mainmenu = jQuery(this).next('ul');
                if (mainmenu.hasClass('open')) {
                    mainmenu.slideToggle().removeClass('open');
                } else {
                    jQuery('ul.mobile-menu').slideToggle().addClass('open');
                    if (settings.format === "dropdown") {
                        mainmenu.find('ul').show();
                    }
                }
            });
            mainmenu.find('li ul').parent().addClass('has-sub');
            mainmenu.find('li ul').addClass('sub-menu');
            multiTg = function () {
                mainmenu.find(".has-sub").prepend('<button class="submenu-button fa fa-plus"></button>');
                mainmenu.find('.submenu-button').on('click', function () {
                    jQuery(this).toggleClass('submenu-opened');
                    if (jQuery(this).siblings('ul').hasClass('open')) {
                        jQuery(this).siblings('ul').removeClass('open').hide();
                    } else {
                        jQuery(this).siblings('ul').addClass('open').show();
                    }
                });
            };
            if (settings.format === 'multitoggle') multiTg();
            else mainmenu.addClass('dropdown');
            if (settings.sticky === true) mainmenu.css('position', 'fixed');
            resizeFix = function () {
                if (jQuery(window).width() > 1024) {
                    mainmenu.find('ul').show();

                }
                if (jQuery(window).width() <= 1024) {
                    mainmenu.find('#menu-button').removeClass('menu-opened');
                    mainmenu.find('ul').hide().removeClass('open');
                }
            };
            resizeFix();
            return jQuery(window).on('resize', resizeFix);
        });
    };
})(jQuery);
jQuery(window).load(function(){
    jQuery('.preloader').delay(400).fadeOut(500);
});
(function ($) {
    jQuery(document).ready(function () {
        jQuery(document).ready(function () {
            jQuery("#mainmenu").menumaker({
                title: "",
                format: "multitoggle"
            });
            var foundActive = false,
                activeElement, linePosition = 0,
                width = 0,
                menuLine = jQuery("#mainmenu #menu-line"),
                lineWidth, defaultPosition, defaultWidth;
            jQuery("#mainmenu > ul > li").each(function () {
                if (jQuery(this).hasClass('current-menu-item')) {
                    activeElement = jQuery(this);
                    foundActive = true;
                }
            });
            if (foundActive != true) {
                activeElement = jQuery("#mainmenu > ul > li").first();
            }
            if (foundActive == true) {
                activeElement = jQuery("#mainmenu > ul > li").first();
            }
            defaultWidth = lineWidth = activeElement.width();
            defaultPosition = linePosition = (activeElement.position())?activeElement.position().left:'';
            menuLine.css("width", lineWidth);
            menuLine.css("left", linePosition);
            jQuery("#mainmenu > ul > li").hover(function () {
                    activeElement = $(this);
                    lineWidth = activeElement.width();
                    linePosition = activeElement.position().left;
                    menuLine.css("width", lineWidth);
                    menuLine.css("left", linePosition);
                },
                function () {
                    menuLine.css("left", defaultPosition);
                    menuLine.css("width", defaultWidth);
                });
        });
        /** Set Position of Sub-Menu **/
        var wapoMainWindowWidth = jQuery(window).width();
        jQuery('#mainmenu ul ul li').mouseenter(function () {
            var subMenuExist = jQuery(this).find('.sub-menu').length;
            if (subMenuExist > 0) {
                var subMenuWidth = jQuery(this).find('.sub-menu').width();
                var subMenuOffset = jQuery(this).find('.sub-menu').parent().offset().left + subMenuWidth;
                if ((subMenuWidth + subMenuOffset) > wapoMainWindowWidth) {
                    jQuery(this).find('.sub-menu').removeClass('submenu-left');
                    jQuery(this).find('.sub-menu').addClass('submenu-right');
                } else {
                    jQuery(this).find('.sub-menu').removeClass('submenu-right');
                    jQuery(this).find('.sub-menu').addClass('submenu-left');
                }
            }
        });
    });
})(jQuery);

jQuery(document).ready(function () {    
    var stickyHeaderTop = jQuery('.scroll-header').offset().top;    
    jQuery(window).scroll(function () {
        if (jQuery(document).width() > 750) {
            jQuery('.home .scroll-header .royals-container').css({display:'none'});
            if (jQuery(window).scrollTop() > stickyHeaderTop) {
                if (jQuery('body').hasClass('logged-in'))
                    jQuery('.scroll-header').css({position: 'fixed', padding: '15px 0', top: '32px'});
                else
                    jQuery('.scroll-header').css({position: 'fixed', padding: '15px 0', top: '0px'});

                jQuery('.home  .scroll-header .royals-container').css({display:'block'});
            }
            else {
                jQuery('.scroll-header').css({position: 'absolute', top: '0px', padding: '0px 0'});
                jQuery('body > section').css({'padding-top': jQuery('.scroll-header').height() + 90});
                 jQuery('.home  .scroll-header .royals-container').css({display:'none'});
            }
        }else{
            jQuery('.home  .scroll-header .royals-container').css({display:'block'});
        }
    });
    var wapoMainWindowWidth =  jQuery(window).width();
        jQuery('.top-menu ul ul li').mouseenter(function () {
            var subMenuExist = jQuery(this).find('.sub-menu').length;
            if (subMenuExist > 0) {
                var subMenuWidth = jQuery(this).find('.sub-menu').width();
                var subMenuOffset = jQuery(this).find('.sub-menu').parent().offset().left + subMenuWidth;
                if ((subMenuWidth + subMenuOffset) > wapoMainWindowWidth) {
                    jQuery(this).find('.sub-menu').removeClass('submenu-left');
                    jQuery(this).find('.sub-menu').addClass('submenu-right');
                } else {
                    jQuery(this).find('.sub-menu').removeClass('submenu-right');
                    jQuery(this).find('.sub-menu').addClass('submenu-left');
                }
            }
    });
   
});
/*Mobile Nav*/
function resize() {
    if (jQuery(window).width() <= 1024) {
        jQuery('#mainmenu > ul').addClass('mobile-menu');
    } else {
        jQuery('#mainmenu > ul').removeClass('mobile-menu');
    }
}
jQuery(document).ready(function (e) {
    jQuery(window).resize(resize);
    resize();   
    
    jQuery(".arrow").on("click", function () {		
		
        if (jQuery('body').hasClass('logged-in')) {
			jQuery("html, body").animate({scrollTop: jQuery("#myId").offset().top+jQuery('#wpadminbar').height()}, 1e3)                
        }
        else {
            jQuery("html, body").animate({scrollTop: jQuery("#myId").offset().top}, 1e3)
        }	
        
    })
});
