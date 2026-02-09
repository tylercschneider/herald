# Herald

A mountable Rails engine that provides a complete blog with admin UI, public views, RSS/Atom feeds, and a JSON API.

## Installation

Add to your Gemfile:

```ruby
gem "herald"
```

Run the install generator:

```bash
rails generate herald:install
rails db:migrate
```

This creates:
- Database migrations for posts, categories, tags, and revisions
- An initializer at `config/initializers/herald.rb`
- Engine routes mounted at `/herald`

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

## Webhooks

When `webhook_url` and `webhook_secret` are configured, Herald sends a POST request when a post is published. The payload is signed with HMAC-SHA256 in the `X-Herald-Signature` header.

## Dependencies

- Rails >= 7.0
- Ruby >= 3.0
- PostgreSQL
- [Pagy](https://github.com/ddnexus/pagy) >= 6.0

## License

MIT
