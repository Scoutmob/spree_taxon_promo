module Spree
  class Calculator::FlatPercentTaxonTotal < Calculator
    preference :flat_percent, :decimal, :default => 0
    preference :taxon, :string, :default => ''
    
    attr_accessible :preferred_flat_percent, :preferred_taxon

    def self.description
      I18n.t(:flat_percent_taxon)
    end

    def compute(object)
      return 0 if object.nil?

      item_total = if preferred_taxon.present?
        item_total_from_preferred_taxon(object)

      elsif compute_item_total_on_promotion?
        item_total_from_promotion(object)

      else
        object.line_items.map(&:amount).sum
      end

      value = item_total * BigDecimal(self.preferred_flat_percent.to_s) / 100.0
      (value * 100).round.to_f / 100
    end

    protected

      def item_total_from_preferred_taxon(order)
        order.line_items.sum do |line_item|
          value_for_line_item(line_item)
        end
      end

      # Calculates the discount value of each line item. Returns zero
      # unless the product is a preferred taxon.
      def value_for_line_item(line_item)
        return 0 unless line_item_eligible?(line_item)
        line_item.total
      end

      def line_item_eligible?(line_item)
        line_item.product.taxons.where(:name => preferred_taxon_names).present?
      end

      def preferred_taxon_names
        preferred_taxon.split(/\s*,\s*/)
      end

      def compute_item_total_on_promotion?
        self.calculable.respond_to?(:promotion) and self.calculable.promotion.rules.any? { |r| r.respond_to?(:promotional_item_total) }
      end

      def item_total_from_promotion(order)
        self.calculable.promotion.rules.sum { |r| r.respond_to?(:promotional_item_total) ? r.promotional_item_total(order) : 0 }
      end

  end
end
