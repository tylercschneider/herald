# Herald

[![CI](https://github.com/tylercschneider/herald/actions/workflows/ci.yml/badge.svg)](https://github.com/tylercschneider/herald/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/herald.svg)](https://rubygems.org/gems/herald)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A mountable Rails engine that provides a complete blog with admin UI, public views, RSS/Atom feeds, and a JSON API.

## Installation

Add to your Gemfile:

```ruby
gem "herald"
```

Run the install generator:

```bash
rails generate herald:install
rails herald:install:migrations
rails db:migrate
```

This creates:
- An initializer at `config/initializers/herald.rb`
- Engine routes mounted at `/herald`
- Database migrations for posts, categories, tags, and revisions

## Configuration

Edit `config/initializers/herald.rb`:

```ruby
Herald.configure do |config|
  # The model class that represents post authors
  config.author_class = "User"

  # Application name used in RSS/Atom feeds
  config.application_name = "My Blog"

  # Method called to authenticate admin users
  config.authentication_method = :authenticate_user!

  # Method that returns the current author for new posts
  config.current_author_method = :current_user

  # Method called to authenticate API requests
  config.api_authentication_method = :authenticate_api_user!

  # Layout for admin views
  config.admin_layout = "application"

  # Layout for public blog views
  config.blog_layout = "application"

  # Optional: webhook URL to notify on publish (HMAC-SHA256 signed)
  # config.webhook_url = "https://example.com/webhook"
  # config.webhook_secret = "your-secret"
end
```

The author model must respond to `name`.

## Routes

Mount the engine in `config/routes.rb` (the generator does this automatically):

```ruby
mount Herald::Engine => "/herald"
```

This provides:

### Public Blog
| Path | Description |
|------|-------------|
| `/herald/blog` | Blog index with search |
| `/herald/blog/:slug` | Single post |
| `/herald/blog/category/:slug` | Posts by category |
| `/herald/blog/tag/:slug` | Posts by tag |
| `/herald/blog/feed` | RSS feed |
| `/herald/blog/atom` | Atom feed |
| `/herald/blog/sitemap` | XML sitemap |

### Admin
| Path | Description |
|------|-------------|
| `/herald/posts` | Manage posts |
| `/herald/categories` | Manage categories |

### API
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/herald/api/posts` | List posts |
| `POST` | `/herald/api/posts` | Create post |
| `GET` | `/herald/api/posts/:id` | Show post |
| `PATCH` | `/herald/api/posts/:id` | Update post |
| `DELETE` | `/herald/api/posts/:id` | Delete post |
| `GET` | `/herald/api/posts/by_slug/:slug` | Find post by slug |
| `POST` | `/herald/api/posts/bulk` | Bulk publish/unpublish/delete |
| `GET/POST/PATCH/DELETE` | `/herald/api/categories` | CRUD categories |
| `GET/POST/PATCH/DELETE` | `/herald/api/tags` | CRUD tags |

#### Filtering and search

```
GET /herald/api/posts?q=search+term
GET /herald/api/posts?category_slug=tutorials
GET /herald/api/posts?tag_slug=ruby
GET /herald/api/posts?include_drafts=true
GET /herald/api/posts?page=2
```

API responses use `data`/`meta` wrapping with pagination metadata:

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 100
  }
}
```

## Features

- Rich text editing with ActionText
- Featured images via ActiveStorage
- Categories and tags
- Post pinning
- Draft preview
- Revision history
- Slug editing
- Reading time estimates
- Scheduled publishing
- View count tracking (with bot filtering)
- Related posts (scored by shared categories/tags)
- RSS and Atom feeds
- XML sitemap
- SEO meta tags (Open Graph, Twitter Card, JSON-LD)
- Webhook delivery on publish (HMAC-SHA256 signed)
- Bulk API operations

## API Authentication

Herald delegates API authentication to the host app via `api_authentication_method`. Define this method in your `ApplicationController` (or whichever controller Herald's API inherits from):

```ruby
class ApplicationController < ActionController::Base
  def authenticate_api_user!
    token = request.headers["Authorization"]&.remove("Bearer ")
    @current_user = User.find_by(api_token: token)
    head :unauthorized unless @current_user
  end
end
```

Herald's API controllers call this method as a `before_action`. The method name is configurable — set `config.api_authentication_method` to match your host app's method.

## Webhooks

When `webhook_url` and `webhook_secret` are configured, Herald sends a POST request when a post is published. The payload is signed with HMAC-SHA256 in the `X-Herald-Signature` header. Delivery is retried up to 5 times with polynomial backoff on network errors.

## Scheduled Publishing

Herald includes a `Herald::PublishScheduledPostsJob` that publishes posts whose `published_at` is in the past but are still in draft status. You need to trigger this job on a recurring schedule in your host app.

Example with cron (via [whenever](https://github.com/javan/whenever) or system crontab):

```bash
# Run every 5 minutes
*/5 * * * * cd /path/to/app && bin/rails runner "Herald::PublishScheduledPostsJob.perform_later"
```

Or with [solid_queue](https://github.com/rails/solid_queue) recurring tasks:

```yaml
# config/recurring.yml
publish_scheduled_posts:
  class: Herald::PublishScheduledPostsJob
  schedule: every 5 minutes
```

## Dependencies

- Rails >= 7.0
- Ruby >= 3.0
- PostgreSQL
- [Pagy](https://github.com/ddnexus/pagy) >= 6.0
- [Tailwind CSS](https://tailwindcss.com/) — Herald's built-in views use Tailwind utility classes. If your host app uses a different CSS framework, you can override any view by placing your own version at `app/views/herald/...` following standard Rails engine conventions.

## License

MIT
