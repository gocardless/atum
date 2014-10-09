module Atum
  module Generation
    class ErbContext < Erubis::Context
      def commentify(comment, tabs)
        starter = ('  ' * tabs) + '# '
        max_line_length = 78 - (tabs * 2)
        comment.split("\n")
          .map { |l| l.scan(/.{1,#{max_line_length}}/) }
          .flatten.map { |l| starter + l.strip }.join("\n")
      end

      def method(name, params)
        "#{name}" + (params.length > 0 ? "(#{params})" : '')
      end
    end
  end
end
