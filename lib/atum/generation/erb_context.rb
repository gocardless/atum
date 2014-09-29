module Atum
  module Generation
    class ErbContext < Erubis::Context
      def commentify(comment, tabs)
        starter = ('  ' * tabs) + '# '
        max_line_length = 78 - (tabs * 2)
        comment.split("\n")
               .flat_map { |l| break_line(l, max_line_length) }
               .map { |l| starter + l.strip }
               .join("\n")
      end

      def method(name, params)
        "#{name}" + (params.length > 0 ? "(#{params})" : '')
      end

      def break_line(line, max_line_length)
        line.split.reduce([]) do |lines, word|
          if lines.empty?
            lines = [word]
          elsif (lines[-1] + " #{word}").size > max_line_length
            lines << word
          else
            lines[-1] << " #{word}"
          end
          lines
        end
      end
    end
  end
end
