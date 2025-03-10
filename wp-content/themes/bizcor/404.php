<?php
get_header();
get_template_part('template-parts/section-breadcrumbs');

global $bizcor_options;
$error_code = get_theme_mod('bizcor_error_code',$bizcor_options['bizcor_error_code']);
$error_subtitle = get_theme_mod('bizcor_error_subtitle',$bizcor_options['bizcor_error_subtitle']);
$error_title = get_theme_mod('bizcor_error_title',$bizcor_options['bizcor_error_title']);
$error_desc = get_theme_mod('bizcor_error_desc',$bizcor_options['bizcor_error_desc']);
$error_btn_label = get_theme_mod('bizcor_error_btn_label',$bizcor_options['bizcor_error_btn_label']);
?>
<section id="section-404" class="section-404 st-py-default">
    <div class="container">
        <div class="row wow fadeInUp">
            <div class="col-lg-9 col-12 text-center mx-auto">
                <div class="card-404">
                    <?php if($error_subtitle!=''){ ?>
                    <h2><?php echo esc_html($error_subtitle); ?></h2>
                	<?php } ?>
                    <?php if($error_code!=''){ ?>
                    <h1><?php echo esc_html($error_code); ?></h1>
                	<?php } ?>
                    <?php if($error_title!=''){ ?>
                    <h4><?php echo esc_html($error_title); ?></h4>
                	<?php } ?>
                	 <?php if($error_desc!=''){ ?>
                    <p><?php echo wp_kses_post($error_desc); ?></p>
                    <?php } ?>
                    <a class="btn btn-primary mt-4" href="<?php echo esc_url( home_url( '/' ) ); ?>"><i class="fa fa-arrow-left"></i> <?php echo esc_html($error_btn_label); ?></a>
                </div>
            </div>
        </div>
    </div>
</section>
<?php get_footer(); ?>