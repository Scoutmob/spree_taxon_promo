module Spree
  class Promotion::Rules::ProductBuyTaxonTotal < PromotionRule
    preference :amount, :decimal, :default => 100.00
    preference :operator, :string, :default => '>'
    preference :taxon, :string, :default => ''
    preference :taxon_ids, :string, :default => ''

    attr_accessible :preferred_amount, :preferred_operator, :preferred_taxon, :preferred_taxon_ids

    OPERATORS = ['gt', 'gte']

    def eligible?(order, options = {})
      promotional_item_total(order).send(preferred_operator == 'gte' ? :>= : :>, BigDecimal.new(preferred_amount.to_s))
    end

    def promotional_item_total(order)
      if preferred_taxon.present?
        eligible_taxons = preferred_taxon.split(/\s*,\s*/)
        order.line_items.sum do |line_item|
          line_item.product.taxons.where(:name => eligible_taxons).present? ? line_item.amount : 0
        end
      else
        eligible_taxon_ids = preferred_taxon_ids.split(',').inject(Set.new) { |m,id| m.merge(Taxon.find(id).self_and_descendants.pluck(:id)) }
        order.line_items.sum do |line_item|
          (eligible_taxon_ids & line_item.product.taxon_ids).any? ? line_item.amount : 0
        end
      end
    end
  end
end
