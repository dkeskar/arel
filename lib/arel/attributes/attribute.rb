module Arel
  module Attributes
    class Attribute < Struct.new :relation, :name, :column
      include Arel::Expressions

      def not_eq other
        Nodes::NotEqual.new self, other
      end

      def not_eq_any others
        grouping_any :not_eq, others
      end

      def not_eq_all others
        grouping_all :not_eq, others
      end

      def eq other
        Nodes::Equality.new self, other
      end

      def eq_any others
        grouping_any :eq, others
      end

      def eq_all others
        grouping_all :eq, others
      end

      def in other
        case other
        when Arel::SelectManager
          Nodes::In.new self, other.to_a.map { |x| x.id }
        when Range
          if other.exclude_end?
            left  = Nodes::GreaterThanOrEqual.new(self, other.min)
            right = Nodes::LessThan.new(self, other.max + 1)
            Nodes::And.new left, right
          else
            Nodes::Between.new(self, Nodes::And.new(other.min, other.max))
          end
        else
          Nodes::In.new self, other
        end
      end

      def in_any others
        grouping_any :in, others
      end

      def in_all others
        grouping_all :in, others
      end

      def not_in other
        case other
        when Arel::SelectManager
          Nodes::NotIn.new self, other.to_a.map { |x| x.id }
        when Range
          if other.exclude_end?
            left  = Nodes::LessThan.new(self, other.min)
            right = Nodes::GreaterThanOrEqual.new(self, other.max)
            Nodes::Or.new left, right
          else
            left  = Nodes::LessThan.new(self, other.min)
            right = Nodes::GreaterThan.new(self, other.max)
            Nodes::Or.new left, right
          end
        else
          Nodes::NotIn.new self, other
        end
      end

      def not_in_any others
        grouping_any :not_in, others
      end

      def not_in_all others
        grouping_all :not_in, others
      end

      def matches other
        Nodes::Matches.new self, other
      end

      def matches_any others
        grouping_any :matches, others
      end

      def matches_all others
        grouping_all :matches, others
      end

      def does_not_match other
        Nodes::DoesNotMatch.new self, other
      end

      def does_not_match_any others
        grouping_any :does_not_match, others
      end

      def does_not_match_all others
        grouping_all :does_not_match, others
      end

      def gteq right
        Nodes::GreaterThanOrEqual.new self, right
      end

      def gteq_any others
        grouping_any :gteq, others
      end

      def gteq_all others
        grouping_all :gteq, others
      end

      def gt right
        Nodes::GreaterThan.new self, right
      end

      def gt_any others
        grouping_any :gt, others
      end

      def gt_all others
        grouping_all :gt, others
      end

      def lt right
        Nodes::LessThan.new self, right
      end

      def lt_any others
        grouping_any :lt, others
      end

      def lt_all others
        grouping_all :lt, others
      end

      def lteq right
        Nodes::LessThanOrEqual.new self, right
      end

      def lteq_any others
        grouping_any :lteq, others
      end

      def lteq_all others
        grouping_all :lteq, others
      end

      def asc
        Nodes::Ordering.new self, :asc
      end

      def desc
        Nodes::Ordering.new self, :desc
      end

      private

      def grouping_any method_id, others
        first = send method_id, others.shift

        Nodes::Grouping.new others.inject(first) { |memo,expr|
          Nodes::Or.new(memo, send(method_id, expr))
        }
      end

      def grouping_all method_id, others
        first = send method_id, others.shift

        Nodes::Grouping.new others.inject(first) { |memo,expr|
          Nodes::And.new(memo, send(method_id, expr))
        }
      end
    end

    class String  < Attribute; end
    class Time    < Attribute; end
    class Boolean < Attribute; end
    class Decimal < Attribute; end
    class Float   < Attribute; end
    class Integer < Attribute; end
  end

  Attribute = Attributes::Attribute
end
