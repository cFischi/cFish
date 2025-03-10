<?php
/**
*  Customization options
**/

function rider_sanitize_checkbox( $checked ) {
  return ( ( isset( $checked ) && true == $checked ) ? true : false );
}

function rider_field_sanitize_input_choice( $input, $setting ) {

  // Ensure input is a slug.
  $input = sanitize_key( $input );

  // Get list of choices from the control associated with the setting.
  $choices = $setting->manager->get_control( $setting->id )->choices;

  // If the input is a valid key, return it; otherwise, return the default.
  return ( array_key_exists( $input, $choices ) ? $input : $setting->default );
}
function rider_posts_category(){
  $args = array('parent' => 0);
  $categories = get_categories($args);
  $category = array();
  $category[0]='All';
  $i = 0;
  foreach($categories as $categorys){
      if($i==0){
          $default = $categorys->slug;
          $i++;
      }
      $category[$categorys->term_id] = $categorys->name;
  }
  return $category;
}


function rider_customize_register( $wp_customize ) {
 $rider_options = get_option('rider_theme_options');

  $wp_customize->add_panel(
    'general',
    array(
        'title' => __( 'General', 'rider' ),
        'description' => __('styling options','rider'),
        'priority' => 20, 
    )
  );

  //All our sections, settings, and controls will be added here
  $wp_customize->add_section(
    'TopHeaderSocialLinks',
    array(
      'title' => __('Social Accounts Settings', 'rider'),
      'priority' => 120,
      'description' => __( 'In first input box, you need to add FONT AWESOME shortcode which you can find ' ,  'rider').'<a target="_blank" href="'.esc_url('https://fontawesome.com/icons?from=io').'">'.__('here' ,  'rider').'</a>'.__(' and in second input box, you need to add your social media profile URL.', 'rider').'<br />'.__(' Enter the URL of your social accounts. Leave it empty to hide the icon.' ,  'rider'),
      'panel' => 'general'
    )
  );

$TopHeaderSocialIconDefault = array(
  array('url'=>isset($rider_options['rider_fburl'])?$rider_options['rider_fburl']:'','icon'=>isset($rider_options['rider_fbcode'])?$rider_options['rider_fbcode']:'fa-facebook'),
  array('url'=>isset($rider_options['rider_twiiterurl'])?$rider_options['rider_twiiterurl']:'','icon'=>isset($rider_options['rider_twiitercode'])?$rider_options['rider_twiitercode']:'fa-twitter'),
  array('url'=>isset($rider_options['rider_youturl'])?$rider_options['rider_youturl']:'','icon'=>isset($rider_options['rider_youtcode'])?$rider_options['rider_youtcode']:'fa-youtube'),
  array('url'=>isset($rider_options['rider_insturl'])?$rider_options['rider_insturl']:'','icon'=>isset($rider_options['rider_instcode'])?$rider_options['rider_instcode']:'fa-instagram'),
  array('url'=>isset($rider_options['rider_gplusurl'])?$rider_options['rider_gplusurl']:'','icon'=>isset($rider_options['rider_gpluscode'])?$rider_options['rider_gpluscode']:'fa-google-plus')
  );

$TopHeaderSocialIcon = array();
  for($i=1;$i <= 5;$i++):  
    $TopHeaderSocialIcon[] =  array( 'slug'=>sprintf('TopHeaderSocialIcon%d',$i),   
      'default' => $TopHeaderSocialIconDefault[$i-1]['icon'],   
      'label' => esc_html__( 'Social Account ', 'rider') .$i,   
      'priority' => sprintf('%d',$i) );  
  endfor;
  foreach($TopHeaderSocialIcon as $TopHeaderSocialIcons){
    $wp_customize->add_setting(
      $TopHeaderSocialIcons['slug'],
      array( 
       'default' => $TopHeaderSocialIcons['default'],       
        'capability'     => 'edit_theme_options',
        'type' => 'theme_mod',
        'sanitize_callback' => 'sanitize_text_field',
      )
    );
    $wp_customize->add_control(
      $TopHeaderSocialIcons['slug'],
      array(
        'type'  => 'text',
        'section' => 'TopHeaderSocialLinks',
        'input_attrs' => array( 'placeholder' => esc_attr__('Enter Icon','rider') ),
        'label'      =>   $TopHeaderSocialIcons['label'],
        'priority' => $TopHeaderSocialIcons['priority']
      )
    );
  }
  $TopHeaderSocialIconLink = array();
  for($i=1;$i <= 5;$i++):  
    $TopHeaderSocialIconLink[] =  array( 'slug'=>sprintf('TopHeaderSocialIconLink%d',$i),   
      'default' => $TopHeaderSocialIconDefault[$i-1]['url'],   
      'label' => esc_html__( 'Social Link ', 'rider' ) .$i,
      'priority' => sprintf('%d',$i) );  
  endfor;
  foreach($TopHeaderSocialIconLink as $TopHeaderSocialIconLinks){
    $wp_customize->add_setting(
      $TopHeaderSocialIconLinks['slug'],
      array(
        'default' => $TopHeaderSocialIconLinks['default'],
        'capability'     => 'edit_theme_options',
        'type' => 'theme_mod',
        'sanitize_callback' => 'esc_url_raw',
      )
    );
    $wp_customize->add_control(
      $TopHeaderSocialIconLinks['slug'],
      array(
        'type'  => 'text',
        'section' => 'TopHeaderSocialLinks',
        'priority' => $TopHeaderSocialIconLinks['priority'],
        'input_attrs' => array( 'placeholder' => esc_html__('Enter URL','rider')),
      )
    );
  }
  
  $wp_customize->get_section('title_tagline')->panel = 'general';
  $wp_customize->get_section('static_front_page')->panel = 'general';
  $wp_customize->get_section('header_image')->panel = 'general';
  $wp_customize->get_section('title_tagline')->title = __('Header & Logo','rider');
  
$wp_customize->add_section(
  'headerNlogo',
  array(
    'title' => __('Header & Logo','rider'),
    'panel' => 'general'
  )
);

$wp_customize->add_setting(
  'theme_logo_height',
  array(
    'default' => '',
    'capability'     => 'edit_theme_options',
    'sanitize_callback' => 'absint',
    )
  );
$wp_customize->add_control(
  'theme_logo_height',
  array(
    'section' => 'title_tagline',
    'label'      => __('Enter Logo Size', 'rider'),
    'description' => __("Use if you want to increase or decrease logo size (optional) Don't enter `px` in the string. e.g. 20 (default: 40px)",'rider'),
    'type'       => 'text',
    'priority'    => 50,
    )
  );
$wp_customize->add_section(
    'rider_basic_setting',
    array(
      'title' => __('Basic settings', 'rider'),
      'description' => __('Blog title and background image','rider'),
      'priority' => 120,      
      'panel' => 'general'
    )
  );
$wp_customize->add_setting(
      'rider_logo',
      array(
          'default' => isset($rider_options['rider_logo'])?rider_get_image_id($rider_options['rider_logo']):'',
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'absint',
      )
    );
  $wp_customize->add_control( new WP_Customize_Cropped_Image_Control( $wp_customize, 'rider_logo', array(
      'section'     => 'rider_basic_setting',
      'label'       => __( 'Header Logo Recommended Size (230x220px)' ,'rider'),
      'description' => __( 'Size of Logo should be exactly 230x220px for best results' ,'rider'),
      'flex_width'  => true,
      'flex_height' => true,
      'width'       => 230,
      'height'      => 220,   
      'default-image' => '',      
  ) ) );
$wp_customize->add_setting(
  'rider_blogtitle',
  array(
    'default' => isset($rider_options['rider_blogtitle'])?$rider_options['rider_blogtitle']:'My Blog',
    'capability'     => 'edit_theme_options',
    'sanitize_callback' => 'sanitize_text_field',
    )
  );
$wp_customize->add_control(
  'rider_blogtitle',
  array(
    'section' => 'rider_basic_setting',
    'label'      => __('Enter Blog Title', 'rider'),
    'description' => __("Enter Blog Title",'rider'),
    'type'       => 'text',
    'input_attrs' => array( 'placeholder' => esc_html__('Blog Title','rider')),
    'priority'    => 50,
    )
  );

$wp_customize->add_setting(
      'rider_headertop_bg',
      array(
          'default' => isset($rider_options['rider_headertop-bg'])?rider_get_image_id($rider_options['rider_headertop-bg']):'',
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'absint',
      )
    );
  $wp_customize->add_control( new WP_Customize_Cropped_Image_Control( $wp_customize, 'rider_headertop_bg', array(
      'section'     => 'rider_basic_setting',
      'label'       => __( 'Header Background Image Recommended(1350x667px)' ,'rider'),
      'description' => __( 'Size of Logo should be exactly 1350x667px for best results.' ,'rider'),
      'flex_width'  => true,
      'flex_height' => true,
      'width'       => 1350,
      'height'      => 667,   
      'default-image' => '',
      'priority'    => 60,
  ) ) );  


/*-------------------- Front Page Option Setting --------------------------*/
$wp_customize->add_panel(
    'frontpage_section',
    array(
        'title' => __( 'Front Page Options', 'rider' ),
        'description' => __('Front Page options','rider'),
        'priority' => 20, 
    )
  );


//Title Bar
$wp_customize->add_section( 'frontpage_title_bar_section' ,
   array(
      'title'       => __( 'Front Page : About The Author', 'rider' ),
      'priority'    => 32,
      'capability'     => 'edit_theme_options', 
      'panel' => 'frontpage_section'   
  )
);

/*rider_homepage_sectionswitch*/
$wp_customize->add_setting(
    'rider_homepage_sectionswitch',
    array(
        'default' => '1',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'rider_field_sanitize_input_choice',
    )
);
$wp_customize->add_control(
    'rider_homepage_sectionswitch',
    array(
        'section' => 'frontpage_second_section',
        'label'      => __('About The Author Section', 'rider'),
        'description' => __('About The Author Section hide or show .','rider'),
        'type'       => 'select',
        'choices' => array(
          "1"   => esc_html__( "Show", 'rider' ),
          "2"   => esc_html__( "Hide", 'rider' ),      
        ),
    )
);
$wp_customize->add_setting( 'rider_aboutus_title',
    array(
        'default' => isset($rider_options['rider_aboutus-title'])?$rider_options['rider_aboutus-title']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'sanitize_text_field',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'rider_aboutus_title',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter About Us Title','rider'),
        'type'    => 'text',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter About Us Title','rider')),
    )
);

$wp_customize->add_setting( 'rider_aboutus_name',
    array(
        'default' => isset($rider_options['rider_aboutus-name'])?$rider_options['rider_aboutus-name']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'sanitize_text_field',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'rider_aboutus_name',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter Author Name','rider'),
        'type'    => 'text',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter Author Name','rider')),
    )
);

$wp_customize->add_setting(
  'rider_author_image',
  array(
      'default' => isset($rider_options['rider_author-image'])?rider_get_image_id($rider_options['rider_author-image']):'',
      'capability'     => 'edit_theme_options',
      'sanitize_callback' => 'absint',
  )
);
$wp_customize->add_control( new WP_Customize_Cropped_Image_Control( $wp_customize, 'rider_author_image', array(
  'section'     => 'frontpage_title_bar_section',
  'label'       => __( 'Author image Recommended size(159x159px)' ,'rider'),
  'flex_width'  => true,
  'flex_height' => true,
  'width'       => 159,
  'height'      => 159,   
  'default-image' => '',
) ) );

$wp_customize->add_setting( 'rider_author_link',
    array(
        'default' => isset($rider_options['rider_author-link'])?$rider_options['rider_author-link']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'sanitize_url',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'rider_author_link',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter Author Link','rider'),
        'type'    => 'text',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter Author Link','rider')),
    )
);

$wp_customize->add_setting( 'rider_author_location',
    array(
        'default' => isset($rider_options['rider_author-location'])?$rider_options['rider_author-location']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'sanitize_text_field',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'rider_author_location',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter Author Location','rider'),
        'type'    => 'text',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter Author Location','rider')),
    )
);

$wp_customize->add_setting( 'rider_homemsg',
    array(
        'default' => isset($rider_options['rider_homemsg'])?$rider_options['rider_homemsg']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'wp_kses_post',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'rider_homemsg',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter Short Description','rider'),
        'type'    => 'textarea',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter Short Description','rider')),
    )
);



/* Front page Recent Post section */
$wp_customize->add_section( 'frontpage_second_section' ,
   array(
      'title'       => __( 'Front Page : Blog Post Section', 'rider' ),
      'priority'    => 32,
      'capability'     => 'edit_theme_options', 
      'panel' => 'frontpage_section'   
  )
);

/*rider_homepage_sectionswitch*/
$wp_customize->add_setting(
    'rider_homepage_second_sectionswitch',
    array(
        'default' => '1',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'rider_field_sanitize_input_choice',
    )
);
$wp_customize->add_control(
    'rider_homepage_second_sectionswitch',
    array(
        'section' => 'frontpage_second_section',
        'label'      => __('Blog Post Section', 'rider'),
        'description' => __('Blog Post Section hide or show .','rider'),
        'type'       => 'select',
        'choices' => array(
          "1"   => esc_html__( "Show", 'rider' ),
          "2"   => esc_html__( "Hide", 'rider' ),      
        ),
    )
);

$wp_customize->add_setting( 'rider_homepage_second_section_title',
      array(
          'default' => isset($rider_options['rider_blog-title'])?$rider_options['rider_blog-title']:'',
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'sanitize_text_field',
          'priority' => 20, 
      )
  );
  $wp_customize->add_control( 'rider_homepage_second_section_title',
      array(
          'section' => 'frontpage_second_section',                
          'label'   => __('Enter Recent Post Section Title ','rider'),
          'type'    => 'text',
          'input_attrs' => array( 'placeholder' => esc_html__('Enter Title','rider')),
      )
  );
  
  $wp_customize->add_setting(
    'rider_homepage_second_section_category',
    array(
        'default' => '1',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'rider_field_sanitize_input_choice',
    )
);
$wp_customize->add_control(
    'rider_homepage_second_section_category',
    array(
        'section' => 'frontpage_second_section',
        'label'      => __('Select Category', 'rider'),
        'description' => __('Select Categories of posts for your site , you would like to display in the Home Page.','rider'),
        'type'       => 'select',
        'choices' => rider_posts_category(),
    )
);

//Footer Section
$wp_customize->add_section( 'footerCopyright' , array(
    'title'       => __( 'Footer', 'rider' ),
    'priority'    => 100,
    'capability'     => 'edit_theme_options',
  ) );

$wp_customize->add_setting(
  'rider_footer_logo',
  array(
      'default' => isset($rider_options['rider_footer-logo'])?rider_get_image_id($rider_options['rider_footer-logo']):'',
      'capability'     => 'edit_theme_options',
      'sanitize_callback' => 'absint',
  )
);
$wp_customize->add_control( new WP_Customize_Cropped_Image_Control( $wp_customize, 'rider_footer_logo', array(
  'section'     => 'footerCopyright',
  'label'       => __( 'Footer Logo Recommended size(190x25px)' ,'rider'),
  'flex_width'  => true,
  'flex_height' => true,
  'width'       => 190,
  'height'      => 25,   
  'default-image' => '',
) ) );

$wp_customize->add_setting(
    'rider_footerdescription',
    array(
        'default' => isset($rider_options['rider_footerdescription'])?$rider_options['rider_footerdescription']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'wp_kses_post',
        'priority' => 20, 
    )
);
$wp_customize->add_control(
    'rider_footerdescription',
    array(
        'section' => 'footerCopyright',                
        'label'   => __('Enter Short Description','rider'),
        'description'   => __('100 words short description to display in the footer.','rider'),        
        'type'    => 'textarea',
    )
);

$wp_customize->add_setting(
    'rider_footertext',
    array(
        'default' => isset($rider_options['rider_footertext'])?$rider_options['rider_footertext']:'',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'sanitize_text_field',
        'priority' => 20, 
    )
);
$wp_customize->add_control(
    'rider_footertext',
    array(
        'section' => 'footerCopyright',                
        'label'   => __('Enter Copyright Text','rider'),
        'description'   => __('Some text regarding copyright of your site, you would like to display in the footer.','rider'),        
        'type'    => 'text',
    )
);

// Text Panel Starts Here 

}
add_action( 'customize_register', 'rider_customize_register' );

function rider_custom_css(){
  $rider_options = get_option('rider_theme_options');  
  $custom_css='';
  
  $theme_logo_height = (get_theme_mod('theme_logo_height'))?(get_theme_mod('theme_logo_height')):40;
  $custom_css.= ".logo-fixed img{ max-height: ".esc_attr($theme_logo_height)."px;   }";
  

  $image_id = get_theme_mod('rider_headertop_bg',isset($rider_options['rider_headertop-bg'])?rider_get_image_id($rider_options['rider_headertop-bg']):'');

  $rider_header_bg_img = wp_get_attachment_image_src($image_id,'full');
  if(!empty($rider_header_bg_img)) {
    $custom_css.= '.header_bg { background :url("'.esc_url($rider_header_bg_img[0]).'"); }'; 
  }

  if(display_header_text()){
    $custom_css.=' .home-link {color:#'.get_header_textcolor().'!important;}';
  }

  wp_add_inline_style( 'rider-style', $custom_css ); 
  
}