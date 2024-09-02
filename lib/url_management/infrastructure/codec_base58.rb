# frozen_string_literal: true

module UrlManagement
  module Infrastructure
    module CodecBase58
      ALPHABET_BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
      BASE58 = 58

      # Encodes an integer into a Base58 string.
      #
      # @param [Integer] key The integer to encode.
      # @return [Result::Ok<String>, Result::Err<TypeError, ArgumentError>]
      def self.encode(key)
        return Result.err TypeError.new(key) unless key.is_a?(Integer)
        return Result.err ArgumentError.new(key) unless key.positive?

        encoded = key.digits(BASE58).reverse.map(&->(digit) { ALPHABET_BASE58[digit] }).join
        Result.ok encoded
      end

      # @param [String, #to_str] encoded_string
      # @return [Result::Ok<Integer>, Result::Err<TypeError, ArgumentError>]
      def self.decode(encoded_string = '')
        return Result.err TypeError.new(encoded_string) unless encoded_string.respond_to? :to_str

        encoded_string = encoded_string.to_str
        unless encoded_string.match?(/\A[#{Regexp.escape(ALPHABET_BASE58)}]+\z/)
          return Result.err ArgumentError.new("Input is not Base58 string.")
        end

        decoded_number = encoded_string.chars.reduce(0) do |base10_number, char|
          base10_number * BASE58 + ALPHABET_BASE58.index(char)
        end

        Result.ok decoded_number
      end
    end
  end
end
