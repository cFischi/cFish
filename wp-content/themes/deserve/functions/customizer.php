<?php
/**
*  Customization options
**/

function deserve_sanitize_checkbox( $checked ) {
  return ( ( isset( $checked ) && true == $checked ) ? true : false );
}

function deserve_field_sanitize_input_choice( $input, $setting ) {

  // Ensure input is a slug.
  $input = sanitize_key( $input );

  // Get list of choices from the control associated with the setting.
  $choices = $setting->manager->get_control( $setting->id )->choices;

  // If the input is a valid key, return it; otherwise, return the default.
  return ( array_key_exists( $input, $choices ) ? $input : $setting->default );
}
function deserve_posts_category(){
  $args = array('parent' => 0);
  $categories = get_categories($args);
  $category = array();
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


function deserve_customize_register( $wp_customize ) {
$deserve_options = get_option( 'deserve_theme_options' );

  $wp_customize->add_panel(
    'general',
    array(
        'title' => __( 'General', 'deserve' ),
        'description' => __('styling options','deserve'),
        'priority' => 20, 
    )
  );
  
   //All our sections, settings, and controls will be added here
  $wp_customize->add_section(
    'TopHeaderSocialLinks',
    array(
      'title' => __('Top Header Social Accounts', 'deserve'),
      'priority' => 120,
      'description' => __( 'In first input box, you need to add FONT AWESOME shortcode which you can find ' ,  'deserve').'<a target="_blank" href="'.esc_url('https://fortawesome.github.io/Font-Awesome/icons/').'">'.__('here' ,  'deserve').'</a>'.__(' and in second input box, you need to add your social media profile URL.', 'deserve').'<br />'.__(' Enter the URL of your social accounts. Leave it empty to hide the icon.' ,  'deserve'),
      'panel' => 'general'
    )
  );

$TopHeaderSocialIconDefault = array(
  array('url'=>$deserve_options['fburl'],'icon'=>'fa-facebook'),
  array('url'=>$deserve_options['twitter'],'icon'=>'fa-twitter'),
  array('url'=>$deserve_options['gplus'],'icon'=>'fa-google-plus'),
  array('url'=>$deserve_options['skype'],'icon'=>'fa-linkedin'),
  );

$TopHeaderSocialIcon = array();
  for($i=1;$i <= 4;$i++):  
    $TopHeaderSocialIcon[] =  array( 'slug'=>sprintf('TopHeaderSocialIcon%d',$i),   
      'default' => $TopHeaderSocialIconDefault[$i-1]['icon'],   
      'label' => esc_html__( 'Social Account ', 'deserve') .$i,   
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
        'input_attrs' => array( 'placeholder' => esc_attr__('Enter Icon','deserve') ),
        'label'      =>   $TopHeaderSocialIcons['label'],
        'priority' => $TopHeaderSocialIcons['priority']
      )
    );
  }
  $TopHeaderSocialIconLink = array();
  for($i=1;$i <= 4;$i++):  
    $TopHeaderSocialIconLink[] =  array( 'slug'=>sprintf('TopHeaderSocialIconLink%d',$i),   
      'default' => $TopHeaderSocialIconDefault[$i-1]['url'],   
      'label' => esc_html__( 'Social Link ', 'deserve' ) .$i,
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
        'input_attrs' => array( 'placeholder' => esc_html__('Enter URL','deserve')),
      )
    );
  }
  
  $wp_customize->get_section('title_tagline')->panel = 'general';
  $wp_customize->get_section('static_front_page')->panel = 'general';
  $wp_customize->get_section('header_image')->panel = 'general';
  $wp_customize->get_section('title_tagline')->title = __('Header & Logo','deserve');
  
$wp_customize->add_section(
  'headerNlogo',
  array(
    'title' => __('Header & Logo','deserve'),
    'panel' => 'general'
  )
);

$wp_customize->add_setting(
  'theme_email_id',
  array(
    'default' => $deserve_options['email'],
    'capability'     => 'edit_theme_options',
    'sanitize_callback' => 'sanitize_text_field',
    )
  );
$wp_customize->add_control(
  'theme_email_id',
  array(
    'section' => 'title_tagline',
    'label'      => __('Enter Email id', 'deserve'),
    'description' => __("Enter e-mail id for your site , you would like to display in the Top Header.",'deserve'),
    'type'       => 'text',
    'priority'    => 50,
    )
  );

$wp_customize->add_setting(
  'theme_phone_number',
  array(
    'default' => $deserve_options['phone'],
    'capability'     => 'edit_theme_options',
    'sanitize_callback' => 'sanitize_text_field',
    )
  );
$wp_customize->add_control(
  'theme_phone_number',
  array(
    'section' => 'title_tagline',
    'label'      => __('Enter Phone Number', 'deserve'),
    'description' => __("Enter phone number for your site , you would like to display in the Top Header.",'deserve'),
    'type'       => 'text',
    'priority'    => 54,
    )
  );


/*-------------------- Home Page Option Setting --------------------------*/
$wp_customize->add_panel(
    'frontpage_section',
    array(
        'title' => __( 'Front Page Options', 'deserve' ),
        'description' => __('Front Page options','deserve'),
        'priority' => 20, 
    )
  );



$wp_customize->add_section( 'frontpage_slider_section' ,
   array(
      'title'       => __( 'Front Page : Banner Slider', 'deserve' ),
      'priority'    => 32,
      'capability'     => 'edit_theme_options', 
      'panel' => 'frontpage_section'   
  )
);
 for($i=1;$i <= 5;$i++):  

    $wp_customize->add_setting(
        'deserve_homepage_sliderimage'.$i.'_image',
        array(
            'default' => deserve_get_image_id_by_url($deserve_options['slider-img-'.$i]),
            'capability'     => 'edit_theme_options',
            'sanitize_callback' => 'absint',
        )
    );
    $wp_customize->add_control( new WP_Customize_Cropped_Image_Control( $wp_customize, 'deserve_homepage_sliderimage'.$i.'_image', array(
        'section'     => 'frontpage_slider_section',
        'label'       => __( 'Upload Slider Image ' ,'deserve').$i,
        'flex_width'  => true,
        'flex_height' => true,
        'width'       => 1350,
        'height'      => 550,   
        'default-image' => '',
    ) ) );

    $wp_customize->add_setting( 'deserve_homepage_sliderimage'.$i.'_title',
        array(
          'default' => (isset($deserve_options['slidercontent-'.$i]))?$deserve_options['slidercontent-'.$i]:'',
            'capability'     => 'edit_theme_options',
            'sanitize_callback' => 'sanitize_text_field',
            'priority' => 20, 
        )
    );
    $wp_customize->add_control( 'deserve_homepage_sliderimage'.$i.'_title',
        array(            
            'section' => 'frontpage_slider_section',                
            'label'   => __('Enter Slider Title ','deserve').$i,
            'type'    => 'text',
            'input_attrs' => array( 'placeholder' => esc_html__('Enter Slider Title','deserve')),
        )
    ); 

    $wp_customize->add_setting( 'deserve_homepage_sliderimage'.$i.'_subtitle',
        array(
          'default' => '',
            'capability'     => 'edit_theme_options',
            'sanitize_callback' => 'wp_kses_post',
            'priority' => 20, 
        )
    );
    $wp_customize->add_control( 'deserve_homepage_sliderimage'.$i.'_subtitle',
        array(            
            'section' => 'frontpage_slider_section',                
            'label'   => __('Enter Slider Title ','deserve').$i,
            'type'    => 'textarea',
            'input_attrs' => array( 'placeholder' => esc_html__('Enter Slider Sub Title','deserve')),
        )
    );        
    $wp_customize->add_setting( 'deserve_homepage_sliderimage'.$i.'_link',
        array(
            'default' => '',
            'capability'     => 'edit_theme_options',
            'sanitize_callback' => 'esc_url_raw',
            'priority' => 20, 
        )
    );
    $wp_customize->add_control( 'deserve_homepage_sliderimage'.$i.'_link',
        array(
            'section' => 'frontpage_slider_section',                
            'label'   => __('Enter Slider Link ','deserve').$i,
            'type'    => 'text',
            'input_attrs' => array( 'placeholder' => esc_html__('Enter Slider URL','deserve')),
        )
    );
 endfor;

//Title Bar
$wp_customize->add_section( 'frontpage_title_bar_section' ,
   array(
      'title'       => __( 'Front Page : Title Bar', 'deserve' ),
      'priority'    => 32,
      'capability'     => 'edit_theme_options', 
      'panel' => 'frontpage_section'   
  )
);
$wp_customize->add_setting( 'deserve_homepage_section_title',
    array(
        'default' => $deserve_options['home-title'],
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'sanitize_text_field',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'deserve_homepage_section_title',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter Title ','deserve'),
        'description' => __("Enter home page title for your site , you would like to display in the Home Page.",'deserve'),
        'type'    => 'text',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter Title','deserve')),
    )
);

$wp_customize->add_setting( 'deserve_homepage_section_desc',
    array(  
        'default' => $deserve_options['home-content'],    
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'wp_kses_post',
        'priority' => 20, 
    )
);
$wp_customize->add_control( 'deserve_homepage_section_desc',
    array(
        'section' => 'frontpage_title_bar_section',                
        'label'   => __('Enter Short Description ','deserve'),
        'description' => __("Enter content for your site , you would like to display in the Home Page.",'deserve'),
        'type'    => 'textarea',
        'input_attrs' => array( 'placeholder' => esc_html__('Enter Description','deserve')),
    )
); 

/* Front page First section */
$wp_customize->add_section( 'frontpage_first_section' ,
   array(
      'title'       => __( 'Front Page : First Section', 'deserve' ),
      'priority'    => 32,
      'capability'     => 'edit_theme_options', 
      'panel' => 'frontpage_section'   
  )
);

/*deserve_homepage_sectionswitch*/
$wp_customize->add_setting(
    'deserve_homepage_first_sectionswitch',
    array(
        'default' => '1',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'deserve_field_sanitize_input_choice',
    )
);
$wp_customize->add_control(
    'deserve_homepage_first_sectionswitch',
    array(
        'section' => 'frontpage_first_section',
        'label'      => __('Service Section', 'deserve'),
        'description' => __('Service Section hide or show .','deserve'),
        'type'       => 'select',
        'choices' => array(
          "1"   => esc_html__( "Show", 'deserve' ),
          "2"   => esc_html__( "Hide", 'deserve' ),      
        ),
    )
);

for($i=1;$i <= 3;$i++):
   $wp_customize->add_setting(
        'deserve_homepage_first_section'.$i.'_image',
        array(
            'default' => deserve_get_image_id_by_url($deserve_options['home-icon-'.$i]),
            'capability'     => 'edit_theme_options',
            'sanitize_callback' => 'absint',
        )
    );
    $wp_customize->add_control( new WP_Customize_Cropped_Image_Control( $wp_customize, 'deserve_homepage_first_section'.$i.'_image', array(
        'section'     => 'frontpage_first_section',
        'label'       => __( 'Upload Service Image ' ,'deserve').$i,
        'flex_width'  => true,
        'flex_height' => true,
        'width'       => 150,
        'height'      => 150,   
        'default-image' => '',
    ) ) );

  $wp_customize->add_setting( 'deserve_homepage_first_section'.$i.'_title',
      array(
          'default' => $deserve_options['section-title-'.$i],
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'sanitize_text_field',
          'priority' => 20, 
      )
  );
  $wp_customize->add_control( 'deserve_homepage_first_section'.$i.'_title',
      array(
          'section' => 'frontpage_first_section',                
          'label'   => __('Enter Service Title ','deserve').$i,
          'type'    => 'text',
          'input_attrs' => array( 'placeholder' => esc_html__('Enter title','deserve')),
      )
  );

  $wp_customize->add_setting( 'deserve_homepage_first_section'.$i.'_desc',
      array( 
          'default' => $deserve_options['section-content-'.$i],     
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'wp_kses_post',
          'priority' => 20, 
      )
  );
  $wp_customize->add_control( 'deserve_homepage_first_section'.$i.'_desc',
      array(
          'section' => 'frontpage_first_section',                
          'label'   => __('Enter Service Description ','deserve').$i,
          'type'    => 'textarea',
          'input_attrs' => array( 'placeholder' => esc_html__('Enter Description','deserve')),
      )
  );

  $wp_customize->add_setting( 'deserve_homepage_first_section'.$i.'_link',
      array(
          'default' => $deserve_options['section-link-' . $i],
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'esc_url_raw',
          'priority' => 20, 
      )
  );
  $wp_customize->add_control( 'deserve_homepage_first_section'.$i.'_link',
      array(
          'section' => 'frontpage_first_section',                
          'label'   => __('Enter Service Link ','deserve').$i,
          'type'    => 'text',
          'input_attrs' => array( 'placeholder' => esc_html__('Enter URL','deserve')),
      )
  ); 
endfor;

/* Front page Second section */
$wp_customize->add_section( 'frontpage_second_section' ,
   array(
      'title'       => __( 'Front Page : Second Section', 'deserve' ),
      'priority'    => 32,
      'capability'     => 'edit_theme_options', 
      'panel' => 'frontpage_section'   
  )
);

/*deserve_homepage_sectionswitch*/
$wp_customize->add_setting(
    'deserve_homepage_second_sectionswitch',
    array(
        'default' => '1',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'deserve_field_sanitize_input_choice',
    )
);
$wp_customize->add_control(
    'deserve_homepage_second_sectionswitch',
    array(
        'section' => 'frontpage_second_section',
        'label'      => __('Second Section', 'deserve'),
        'description' => __('Second Section hide or show .','deserve'),
        'type'       => 'select',
        'choices' => array(
          "1"   => esc_html__( "Show", 'deserve' ),
          "2"   => esc_html__( "Hide", 'deserve' ),      
        ),
    )
);

$wp_customize->add_setting( 'deserve_homepage_second_section_title',
      array(
          'default' => (isset($deserve_options['shome-title']))?$deserve_options['shome-title']:'',
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'sanitize_text_field',
          'priority' => 20, 
      )
  );
  $wp_customize->add_control( 'deserve_homepage_second_section_title',
      array(
          'section' => 'frontpage_second_section',                
          'label'   => __('Enter Second Section Title ','deserve'),
          'type'    => 'text',
          'input_attrs' => array( 'placeholder' => esc_html__('Enter Title','deserve')),
      )
  );

  $wp_customize->add_setting( 'deserve_homepage_second_section_desc',
      array( 
          'default' => (isset($deserve_options['shome-content']))?$deserve_options['shome-content']:'',     
          'capability'     => 'edit_theme_options',
          'sanitize_callback' => 'wp_kses_post',
          'priority' => 20, 
      )
  );
  $wp_customize->add_control( 'deserve_homepage_second_section_desc',
      array(
          'section' => 'frontpage_second_section',                
          'label'   => __('Enter Short Description','deserve'),
          'type'    => 'textarea',
          'input_attrs' => array( 'placeholder' => esc_html__('Enter Description','deserve')),
      )
  );
  $wp_customize->add_setting(
    'deserve_homepage_second_section_perpage',
    array(
        'default' => '1',
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'absint',
    )
);
$wp_customize->add_control(
    'deserve_homepage_second_section_perpage',
    array(
        'section' => 'frontpage_second_section',
        'label'      => __('Entet Latest Blog Per Page', 'deserve'),
        'description' => __('Entet Latest Blog Per Page , you would like to display in the Home Page.','deserve'),
        'type'       => 'number',        
    )
);


//Footer Section
$wp_customize->add_section( 'footerCopyright' , array(
    'title'       => __( 'Footer', 'deserve' ),
    'priority'    => 100,
    'capability'     => 'edit_theme_options',
  ) );

$wp_customize->add_setting(
    'footertext',
    array(
        'default' => $deserve_options['footertext'],
        'capability'     => 'edit_theme_options',
        'sanitize_callback' => 'wp_kses_post',
        'priority' => 20, 
    )
);
$wp_customize->add_control(
    'footertext',
    array(
        'section' => 'footerCopyright',                
        'label'   => __('Enter Copyright Text','deserve'),
        'type'    => 'textarea',
    )
);

// Text Panel Starts Here 

}
add_action( 'customize_register', 'deserve_customize_register' );