require 'spec_helper'

describe AbstractFeatureBranch::FileBeautifier do
  describe '#process' do
    before do
      @ugly_config_application_root = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config'))
      @ugly_config_application_reference_root = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config_reference'))
      FileUtils.rm_rf( @ugly_config_application_root)
      FileUtils.cp_r(@ugly_config_application_reference_root, @ugly_config_application_root)
    end
    after do
      FileUtils.rm_rf( @ugly_config_application_root)
    end

    context "a file is specified" do
      it 'gets rid of extra empty lines' do
        feature_file_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config', 'config', 'features.yml'))
        AbstractFeatureBranch::FileBeautifier.process(feature_file_path)
        File.open(feature_file_path, 'r') do |file|
          file.readlines.join.should == <<-EXPECTED_FILE_CONTENT
defaults: &defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

development:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

test:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

production:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

          EXPECTED_FILE_CONTENT
        end
      end

      it 'sorts features by name under each section (e.g. environment)' do
        local_feature_file_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config', 'config', 'features.local.yml'))
        AbstractFeatureBranch::FileBeautifier.process(local_feature_file_path)
        File.open(local_feature_file_path, 'r') do |file|
          file.readlines.join.should == <<-EXPECTED_FILE_CONTENT
defaults: &defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

development:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

test:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

production:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

          EXPECTED_FILE_CONTENT
        end
      end

      it 'handles comments by ignoring comments on top and deleting comments in the middle' do
        feature_file_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config', 'config', 'features', 'including_comments.local.yml'))
        AbstractFeatureBranch::FileBeautifier.process(feature_file_path)
        File.open(feature_file_path, 'r') do |file|
          file.readlines.join.should == <<-EXPECTED_FILE_CONTENT
# This file allows you to override any feature configuration locally without it being committed to git
# It is recommended to use this file only for temporary overrides. Once done, make final change in main .yml
defaults: &defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

development:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

test:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

production:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

          EXPECTED_FILE_CONTENT
        end
      end

      it 'processes a feature empty config file' do
        feature_file_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config', 'config', 'features', 'feature_empty_config.local.yml'))
        AbstractFeatureBranch::FileBeautifier.process(feature_file_path)
        File.open(feature_file_path, 'r') do |file|
          file.readlines.join.should == <<-EXPECTED_FILE_CONTENT
defaults: &defaults


development:
  <<: *defaults

test:
  <<: *defaults

staging:
  <<: *defaults

production:
  <<: *defaults

          EXPECTED_FILE_CONTENT
        end
      end

      it 'processes an empty file without change or exceptions' do
        feature_file_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config', 'config', 'features', 'empty.local.yml'))
        AbstractFeatureBranch::FileBeautifier.process(feature_file_path)
        File.open(feature_file_path, 'r') do |file|
          file.readlines.join.should be_empty
        end
      end

    end

    context "a directory is specified" do
      it 'beautifies all YAML files under specified directory recursively' do
        feature_directory_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config', 'config', 'features'))
        AbstractFeatureBranch::FileBeautifier.process(feature_directory_path)

        ['public.yml', 'public.local.yml', 'admin.yml', 'admin.local.yml', 'internal/wiki.yml', 'internal/wiki.local.yml'].each do |file_path_suffix|
          file_path = File.join(feature_directory_path, file_path_suffix)
          File.open(file_path, 'r') do |file|
            file.readlines.join.should == <<-EXPECTED_FILE_CONTENT
defaults: &defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

development:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

test:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

production:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

            EXPECTED_FILE_CONTENT
          end
        end
      end

      context "no file or directory is specified (process all feature files)" do
        after do
          AbstractFeatureBranch.initialize_application_root
          AbstractFeatureBranch.load_application_features
        end
        it 'beautifies all feature files in the application' do
          AbstractFeatureBranch.application_root = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config'))
          AbstractFeatureBranch.load_application_features
          AbstractFeatureBranch::FileBeautifier.process

          [
            'features.yml',
            'features.local.yml',
            'features/public.yml',
            'features/public.local.yml',
            'features/admin.yml',
            'features/admin.local.yml',
            'features/internal/wiki.yml',
            'features/internal/wiki.local.yml'
          ].each do |file_path_suffix|
            file_path = File.join(AbstractFeatureBranch.application_root, 'config', file_path_suffix)
            File.open(file_path, 'r') do |file|
              file.readlines.join.should == <<-EXPECTED_FILE_CONTENT
defaults: &defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

development:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

test:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

staging:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

production:
  <<: *defaults
  FEATURE1: true
  Feature2: true
  feature3: false
  feature4: true
  feature4a: true

              EXPECTED_FILE_CONTENT
            end
          end
        end

        it 'does not beautify non-feature files in the application' do
          AbstractFeatureBranch.application_root = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'application_ugly_config'))
          AbstractFeatureBranch.load_application_features
          AbstractFeatureBranch::FileBeautifier.process

          file_path = File.join(AbstractFeatureBranch.application_root, 'config', 'another_application_configuration.yml')
          File.open(file_path, 'r') do |file|
            file.readlines.join.should == <<-ANOTHER_APPLICATION_CONFIGURATION_CONTENT
common: &default_settings
  license_key: <%= ENV["LICENSE_KEY"] %>
  app_name: <%= ENV["APP_NAME"] %>
  monitor_mode: true
  developer_mode: false
  log_level: info

  browser_monitoring:
      auto_instrument: true

  audit_log:
    enabled: false


development:
  <<: *default_settings
  monitor_mode: false
  developer_mode: true

test:
  <<: *default_settings
  monitor_mode: false

production:
  <<: *default_settings
  monitor_mode: true

staging:
  <<: *default_settings
  monitor_mode: true
  app_name: <%= ENV["APP_NAME"] %> (Staging)
            ANOTHER_APPLICATION_CONFIGURATION_CONTENT
          end

          file_path = File.join(AbstractFeatureBranch.application_root, 'config', 'database.yml')
          File.open(file_path, 'r') do |file|
            file.readlines.join.should == <<-DATABASE_CONFIGURATION_CONTENT
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000

test:
  adapter: sqlite3
  database: db/test.sqlite3
  pool: 5
  timeout: 5000

production:
  adapter: sqlite3
  database: db/production.sqlite3
  pool: 5
  timeout: 5000
            DATABASE_CONFIGURATION_CONTENT
          end
        end
      end
    end
  end
end
