require_relative 'member_table'
require_relative 'constituency_member'

class ConstituencyMemberTable < MemberTable
  field :members do
    table.xpath('.//tr[td]').map do |tr|
      ConstituencyMember.new(noko: tr, response: response).to_h
    end
  end
end
