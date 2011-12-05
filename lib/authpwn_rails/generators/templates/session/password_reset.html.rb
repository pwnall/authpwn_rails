<%= form_for @credential, :url => reset_password_session_path do |f| %>
  <section class="fields">
  <% unless @credential.new_record? %>
  <div class="field">
    <%= label_tag :old_password, 'Current Password' %><br />
    <span class="value">
      <%= password_field_tag :old_password %>
    </span>
  </div>
  <% end %>
  
  <div class="field">
    <%= f.label_tag :password, 'New Password' %><br />
    <span class="value">
      <%= f.password_field :password %>
    </span
  </div>

  <div class="field">
    <%= f.label_tag :password_confirmation, 'Re-enter New Password' %><br />
    <span class="value">
      <%= f.password_field :password_confirmation %>
    </span
  </div>
  </section>
  
  <p class="action">
    <%= submit_tag 'Log in' %>
  </p>
<% end %>
