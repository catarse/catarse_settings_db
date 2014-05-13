module CatarseSettingsDb
  class Setting < ActiveRecord::Base
    self.table_name = 'settings'

    validates :name, presence: true
    class << self
      # This method returns the values of the config simulating a Hash, like:
      #   Configuration[:foo]
      # It can also bring Arrays of keys, like:
      #   Configuration[:foo, :bar]
      # ... so you can pass it to a method using *.
      # It is memoized, so it will be correctly cached.
      def [] *keys
        if keys.size == 1
          get keys.shift
        else
          keys.map { |key| get key }
        end
      end
      def []= key, value
        set key, value
      end

      private
      def get key
        Rails.cache.fetch("/configurations/#{key}") do
          find_by_name(key).value rescue nil
        end
      end

      def set key, value
        find_or_create_by!(name: key).update(value: value)
        Rails.cache.write("/configurations/#{key}", value)
        value
      end

    end
  end
end
