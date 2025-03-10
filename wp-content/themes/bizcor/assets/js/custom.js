(function($) {

  'use strict';

  $(document).ready(function() {
    
    // Preloader
    $(window).on('load', function() {
      $('.preloader').fadeOut('1000', function() {
        $(this).remove();
      });
    });

    // BackTotop Button
    if($('.prgoress_scrollingUp path').length){
        var progressPath = document.querySelector('.prgoress_scrollingUp path');
        var pathLength = progressPath.getTotalLength();
        progressPath.style.transition = progressPath.style.WebkitTransition = 'none';
        progressPath.style.strokeDasharray = pathLength + ' ' + pathLength;
        progressPath.style.strokeDashoffset = pathLength;
        progressPath.getBoundingClientRect();
        progressPath.style.transition = progressPath.style.WebkitTransition = 'stroke-dashoffset 10ms linear';
        var updateProgress = function () {
          var scroll = $(window).scrollTop();
          var height = $(document).height() - $(window).height();
          var progress = pathLength - (scroll * pathLength / height);
          progressPath.style.strokeDashoffset = progress;
        }
        updateProgress();
        $(window).on('scroll', updateProgress);
        var offset = 250;
        var duration = 550;
        jQuery(window).on('scroll', function () {
          if (jQuery(this).scrollTop() > offset) {
            jQuery('.prgoress_scrollingUp').addClass('is-active');
          } else {
            jQuery('.prgoress_scrollingUp').removeClass('is-active');
          }
        });

        jQuery('.prgoress_scrollingUp').on('click', function (event) {
          event.preventDefault();
          jQuery('html, body').animate({ scrollTop: 0 }, duration);
          return false;
        });
    }

    // Sticky Header
    if ($(".is-sticky-on").length > 0) {
      $(window).on('scroll', function() {
        if ($(window).scrollTop() >= 250) {
          $('.is-sticky-on').addClass('is-sticky-menu');
        } else {
          $('.is-sticky-on').removeClass('is-sticky-menu');
        }
      });
    }

    // Homepage Banner Slider
    if ($(".home-slider").length > 0) {
      var $owlHome = $('.home-slider');
      $owlHome.owlCarousel({
        rtl: $("html").attr("dir") == 'rtl' ? true : false,
        items: 1,
        autoplay: true,
        autoplayTimeout: bizcor_settings.slider_speed,
        animateIn: bizcor_settings.slider_animation_start,
        animateOut: bizcor_settings.slider_animation_end,
        margin: 0,
        loop: true,
        dots: true,
        nav: true,
        navText: ['<i class="fas fa-arrow-left"></i>', '<i class="fas fa-arrow-right"></i>'],
        singleItem: true,
        transitionStyle: "fade",
        responsive: {
          0: {
            nav: false
          },
          575: {
            nav: $(".slider-section").hasClass('') == 'home-slider-one' ? true : false
          },
          992: {
            nav: $(".slider-section").hasClass('') == 'home-slider-one' ? true : false
          }
        }
      });
      $owlHome.owlCarousel();
      $owlHome.on('translate.owl.carousel', function(event) {
        var data_anim = $("[data-animation]");
        data_anim.each(function() {
          var anim_name = $(this).data('animation');
          $(this).removeClass('animated ' + anim_name).css('opacity', '0');
        });
      });
      $("[data-delay]").each(function() {
        var anim_del = $(this).data('delay');
        $(this).css('animation-delay', anim_del);
      });
      $("[data-duration]").each(function() {
        var anim_dur = $(this).data('duration');
        $(this).css('animation-duration', anim_dur);
      });
      $owlHome.on('translated.owl.carousel', function() {
        var data_anim = $owlHome.find('.owl-item.active').find("[data-animation]");
        data_anim.each(function() {
          var anim_name = $(this).data('animation');
          $(this).addClass('animated ' + anim_name).css('opacity', '1');
        });
      });
    }

    $(document).ready(function() {
      var maxCount = $('.home-slider .owl-dots button.owl-dot');
      var spans = $('.home-slider .owl-dots button.owl-dot span');
      if (spans.length === maxCount.length) {
        spans.each(function(key, index) {
          var count = key + 1;
          var formattedNumber = ("0" + count).slice(-2);
          // Update the text content of each span with the corresponding number
          $(this).text(formattedNumber);
        });
      }
    });

    // Service Load More Button
    $(".service-home .st-load-item").slice(0, 3).show();
    $(".service-home .st-load-btn").on('click', function(e) {
      e.preventDefault();
      $(".service-home .st-load-btn").addClass("loadspinner");
      $(".service-home .st-load-btn").animate({
          display: "block"
        }, 2500,
        function() {
          $(".service-home .st-load-item:hidden").slice(0, 3).slideDown();
          if ($(".service-home .st-load-item:hidden").length === 0) {
            $(".service-home .st-load-btn").text(bizcor_settings.no_more_btn_label);
          }
          $(".service-home .st-load-btn").removeClass("loadspinner");
        }
      );
    });

    // Testimonial
    if ($(".testimonials-slider").length > 0) {
      var owlTestimonial = $(".testimonials-slider");
      owlTestimonial.owlCarousel({
        rtl: $("html").attr("dir") == 'rtl' ? true : false,
        loop: true,
        nav: true,
        margin: 30,
        mouseDrag: true,
        touchDrag: true,
        autoplay: true,
        autoplayTimeout: 6000,
        navText: ["<i class='fa fa-arrow-left'></i>", "<i class='fa fa-arrow-right'></i>"],
        responsive: {
          0: {
            stagePadding: 10,
            dots: false,
            items: 1
          },
          768: {
            stagePadding: 10,
            dots: false,
            items: 1
          },
          992: {
            stagePadding: 15,
            dots: false,
            items: 1
          }
        }
      });
    }

  });
}(jQuery));