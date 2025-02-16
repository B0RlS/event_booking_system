module Callable
  def call(*args, &block)
    binding.pry
    new.(*args, &block).call
  end
end
