<?php
/**
 * @package press_this_auto_close
 * @version 1.1
 */
/*
Plugin Name: Press-this auto close
Plugin URI: http://haoqis.com/
Description: This is a plugin for Press-this tool, it auto close your window when you publish your post
Author: haoqis
Version: 1.1
Author URI: http://haoqis.com/
*/

 
function press_this_auto_close(){
 global $posted;
if ( isset($posted) && intval($posted) ) {
	echo<<<EOT
<script>
	(function(){
		if(jQuery){
				jQuery(function(){
					var message=jQuery('#message a:last');			 
					if(message){					 
						message.before('after 3 seconds ');
					}				
				});
	
		}

		setTimeout(function(){window.close();},3000);
	})();
</script>
EOT;
}
	
}

if(isset($pagenow) && $pagenow=='press-this.php'){
	add_action('admin_head','press_this_auto_close');
}

?>
