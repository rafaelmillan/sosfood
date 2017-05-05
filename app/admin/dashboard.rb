ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    section "Recently updated content" do
      table_for PaperTrail::Version.order('id desc').limit(100) do # Use PaperTrail::Version if this throws an error
        column ("ID") do |v|
          if v.item
            v.item.id
          elsif v.reify
            v.reify.id
          end
        end
        column ("Item") do |v|
          if v.item
            link_to v.item.display_name, [:admin, v.item]
          elsif v.reify
            v.reify.display_name
          end
        end
        column ("Event") { |v| v.event }
        column ("Changes") { |v| v.changeset.keys.join(", ") }
        column ("Modified at") { |v| v.created_at.to_s :long }
        column ("User") { |v| link_to(User.find(v.whodunnit).email, [:admin, User.find(v.whodunnit)]) unless v.whodunnit.nil? }
      end
    end

    # Here is an example of a simple dashboard with columns and panels.

    columns do
      column do
        panel "Pending approvals" do
          ul do
            Distribution.where(status: "pending").map do |dis|
              li link_to(dis.display_name, edit_admin_distribution_path(dis))
            end
          end
        end
      end

      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end
      end
    end
  end # content
end
