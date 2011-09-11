chip "mux" do |s,a,b|
  output { _or ( _and (s, a), _and (_not (s), b) ) }
end

chip 'half-adder' do |a,b|
  sum { _xor(a,b) }
  carry { _and(a,b) }
end
