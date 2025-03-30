# Test-Driven Development Workflow for WordPress Components

## Overview
This document outlines the Test-Driven Development (TDD) workflow for WordPress components at cFish.io. By using TDD with Cursor AI assistance, we can improve code quality, maintainability, and ensure features meet requirements before implementation.

## The TDD Process

### 1. Write a Test First
Before writing any implementation code, write a test that defines the expected behavior.

### 2. Run the Test (It Should Fail)
Run the test to ensure it fails since the implementation doesn't exist yet.

### 3. Write the Implementation
Write the minimum code necessary to make the test pass.

### 4. Run the Test Again (It Should Pass)
Verify that the implementation works correctly by running the test again.

### 5. Refactor the Code
Clean up the code while ensuring tests continue to pass.

### 6. Repeat
Continue the cycle for each new feature or bugfix.

## Using Cursor AI for TDD

### Test Creation Phase

#### Prompt Template for Creating Tests:

```
I need to implement [component/feature name] for WordPress with the following requirements:
[List requirements]

Before implementing the actual code, please create a PHPUnit test class following TDD principles that tests:
1. [Specific functionality]
2. [Edge cases]
3. [Error handling]

The test should be compatible with WordPress test framework and assume the following environment:
- WordPress version: 6.0+
- PHP version: 7.4+
```

#### Example:

```
I need to implement a custom Contact Form plugin for WordPress with the following requirements:
- Store form submissions in a custom database table
- Send email notifications to admin
- Validate inputs (name, email, message)
- Provide AJAX submission option

Before implementing the actual code, please create a PHPUnit test class following TDD principles that tests:
1. Form validation functionality
2. Database storage of submissions
3. Email notification sending
4. AJAX submission handling
5. Error handling for invalid inputs

The test should be compatible with WordPress test framework and assume the following environment:
- WordPress version: 6.0+
- PHP version: 7.4+
```

### Implementation Phase

#### Prompt Template for Implementation:

```
I have created the following test for [component/feature name]:

```php
[Insert your test code here]
```

Now, please implement the minimum code necessary to make this test pass following WordPress best practices, OOP principles, and proper security measures.
```

### Refactoring Phase

#### Prompt Template for Refactoring:

```
The following implementation passes the tests, but needs refactoring for better code quality:

```php
[Insert your implementation code here]
```

Please refactor this code to improve:
1. Readability
2. Maintainability
3. Performance
4. Security

Ensure that all tests still pass after refactoring.
```

## YOLO Mode Configuration for TDD

Configure YOLO mode with the following permissions to enable automatic TDD workflow:

```
Any testing commands are always allowed, including PHPUnit, WP-CLI test, etc.
Basic build commands like composer, npm, etc. are allowed.
Reading and creating files within the project is allowed.
Running database operations within the test environment is allowed.
```

## WordPress Testing Setup

### Prerequisites

- WordPress Core Test Suite
- PHPUnit
- WP-CLI
- Test database configuration

### Setting Up the Testing Environment

1. Install PHPUnit and WordPress test suite:

```bash
composer require --dev phpunit/phpunit
composer require --dev yoast/phpunit-polyfills
composer require --dev wp-cli/wp-cli-bundle
```

2. Create a test configuration file `phpunit.xml.dist`:

```xml
<phpunit
    bootstrap="tests/bootstrap.php"
    backupGlobals="false"
    colors="true"
    convertErrorsToExceptions="true"
    convertNoticesToExceptions="true"
    convertWarningsToExceptions="true"
>
    <testsuites>
        <testsuite name="Default Test Suite">
            <directory suffix=".php">./tests/</directory>
        </testsuite>
    </testsuites>
</phpunit>
```

3. Create a bootstrap file at `tests/bootstrap.php`:

```php
<?php
/**
 * PHPUnit bootstrap file
 */

// Path to the WordPress codebase to test.
$_tests_dir = '/tmp/wordpress-tests-lib';

// Locate wp-tests-config.php if provided or create it.
if ( ! file_exists( $_tests_dir . '/includes/functions.php' ) ) {
    echo "Could not find $_tests_dir/includes/functions.php, have you run bin/install-wp-tests.sh ?" . PHP_EOL;
    exit( 1 );
}

// Give access to tests_add_filter() function.
require_once $_tests_dir . '/includes/functions.php';

// For plugin handling
function _manually_load_plugin() {
    require dirname( dirname( __FILE__ ) ) . '/your-plugin-file.php';
}
tests_add_filter( 'muplugins_loaded', '_manually_load_plugin' );

// Start up the WP testing environment.
require $_tests_dir . '/includes/bootstrap.php';
```

4. Create an installation script `bin/install-wp-tests.sh`:

```bash
#!/usr/bin/env bash

if [ $# -lt 3 ]; then
    echo "usage: $0 <db-name> <db-user> <db-pass> [db-host] [wp-version] [skip-database-creation]"
    exit 1
fi

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
WP_VERSION=${5-latest}
SKIP_DB_CREATE=${6-false}

# Download WordPress test suite
download() {
    if [ `which curl` ]; then
        curl -s "$1" > "$2";
    elif [ `which wget` ]; then
        wget -nv -O "$2" "$1"
    fi
}

# Set up WordPress test suite installation
setup_wp_test_suite() {
    # Further scripting for downloading and configuring WordPress test suite...
    # (Full implementation omitted for brevity)
}

# Call the setup function
setup_wp_test_suite
```

## File Structure for Tests

```
your-plugin/
├── src/                 # Plugin implementation files
├── tests/               # Test files
│   ├── bootstrap.php    # Bootstrap file for PHPUnit
│   ├── class-test-case.php # Custom test case class
│   └── test-*.php       # Individual test files
├── bin/                 # Scripts
│   └── install-wp-tests.sh # Test installation script
├── phpunit.xml.dist     # PHPUnit configuration
└── your-plugin.php      # Main plugin file
```

## Pre-PR Command for Test Verification

Create a pre-PR command to run all tests before submitting changes:

```bash
#!/bin/bash
# pre-pr.sh

echo "Running PHPUnit tests..."
./vendor/bin/phpunit

if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix issues before creating a PR."
    exit 1
fi

echo "Running code standards check..."
./vendor/bin/phpcs

if [ $? -ne 0 ]; then
    echo "Code standards check failed. Please fix issues before creating a PR."
    exit 1
fi

echo "All checks passed. You can proceed with the PR."
exit 0
```

Make the script executable:

```bash
chmod +x pre-pr.sh
```

## Example Test Case

Here's an example test case for a custom WordPress contact form:

```php
<?php
/**
 * Class ContactFormTest
 *
 * @package YourPlugin
 */

class ContactFormTest extends WP_UnitTestCase {

    /**
     * Test form validation functionality.
     */
    public function test_form_validation() {
        $contact_form = new ContactForm();
        
        // Test invalid email
        $result = $contact_form->validate_form([
            'name' => 'Test User',
            'email' => 'invalid-email',
            'message' => 'This is a test message',
        ]);
        $this->assertFalse($result['success']);
        $this->assertContains('email', $result['errors']);
        
        // Test empty name
        $result = $contact_form->validate_form([
            'name' => '',
            'email' => 'test@example.com',
            'message' => 'This is a test message',
        ]);
        $this->assertFalse($result['success']);
        $this->assertContains('name', $result['errors']);
        
        // Test valid form data
        $result = $contact_form->validate_form([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'message' => 'This is a test message',
        ]);
        $this->assertTrue($result['success']);
    }
    
    /**
     * Test database storage of submissions.
     */
    public function test_database_storage() {
        $contact_form = new ContactForm();
        
        $form_data = [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'message' => 'This is a test message',
        ];
        
        $result = $contact_form->store_submission($form_data);
        $this->assertTrue($result > 0); // Should return an ID
        
        // Check if data was stored correctly
        global $wpdb;
        $table_name = $wpdb->prefix . 'contact_form_submissions';
        $submission = $wpdb->get_row("SELECT * FROM $table_name WHERE id = $result");
        
        $this->assertEquals('Test User', $submission->name);
        $this->assertEquals('test@example.com', $submission->email);
        $this->assertEquals('This is a test message', $submission->message);
    }
    
    /**
     * Test email notification functionality.
     */
    public function test_email_notification() {
        // Mock WordPress email function
        add_filter('wp_mail', function($args) {
            $this->assertEquals(get_option('admin_email'), $args['to']);
            $this->assertStringContains('New Contact Form Submission', $args['subject']);
            $this->assertStringContains('Test User', $args['message']);
            $this->assertStringContains('test@example.com', $args['message']);
            $this->assertStringContains('This is a test message', $args['message']);
            return true;
        });
        
        $contact_form = new ContactForm();
        $form_data = [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'message' => 'This is a test message',
        ];
        
        $result = $contact_form->send_notification($form_data);
        $this->assertTrue($result);
    }
}
```

## Best Practices for WordPress TDD

1. **Mock WordPress Functions**: Use the WordPress test suite's mocking capabilities to avoid external dependencies.

2. **Test Database Operations**: Use a test database to ensure your database operations work correctly.

3. **Test Hooks and Filters**: Verify that your plugin properly registers and uses WordPress hooks and filters.

4. **Test Admin and Public Functionality Separately**: Create separate test classes for admin and public-facing functionality.

5. **Test for Security**: Include tests for security features like nonce verification, capability checks, and input sanitization.

6. **Use Data Providers**: Use PHPUnit data providers to test multiple inputs with the same test method.

7. **Test Edge Cases**: Include tests for edge cases and error conditions.

8. **Keep Tests Fast**: Optimize tests for speed to encourage running them frequently.

## Resources and Further Reading

- [WordPress PHPUnit Documentation](https://make.wordpress.org/core/handbook/testing/automated-testing/phpunit/)
- [WP-CLI Testing Documentation](https://make.wordpress.org/cli/handbook/guides/plugin-unit-tests/)
- [PHPUnit Documentation](https://phpunit.readthedocs.io/)
- [TDD for WordPress Plugins](https://carlalexander.ca/test-driven-development-wordpress-plugins/)

_Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 