# authpwn_rails

User authentication for a Ruby on Rails 5 application.

## Integration

Scaffold user accounts, and session controller views.

```bash
rails g authpwn:all
```

Wire authentication into your `ApplicationController`.

```ruby
class ApplicationController
  authenticates_using_session
end
```

Note: the code inside the models and controllers is tucked away in the plug-in.
The scaffold models and controllers are there as extension points. You will be
able to update the plug-in without regenerating the scaffolds.

## Migrating from older versions?

See the legacy/ directory a semi-automated way of migrating your database.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version
  unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a
  commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright 2010-2016 Victor Costan, released under the MIT license.
