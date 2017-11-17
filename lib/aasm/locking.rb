module AASM::Locking
  def aasm_write_state(state, name = :default)
    lock!
    super(state, name)
  end
end
