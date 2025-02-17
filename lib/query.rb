class Query
  class << self
    attr_reader :model

    def set_model(model)
      @model = model
    end

    delegate_missing_to :relation

    private

    def relation
      model.all.extending(self::Scopes)
    end
  end
end
