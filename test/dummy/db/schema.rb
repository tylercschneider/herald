# frozen_string_literal: true

ActiveRecord::Schema[8.1].define(version: 2026_02_07_000001) do
  create_table :users, force: :cascade do |t|
    t.string :name, null: false
    t.string :email, null: false
    t.timestamps
  end

  create_table :herald_posts, force: :cascade do |t|
    t.references :user, null: false, foreign_key: true
    t.string :title, null: false
    t.string :slug, null: false
    t.text :excerpt
    t.string :meta_description
    t.string :og_image
    t.integer :status, default: 0, null: false
    t.boolean :pinned, default: false, null: false
    t.datetime :published_at
    t.timestamps
  end

  add_index :herald_posts, :slug, unique: true
  add_index :herald_posts, [:status, :published_at]

  create_table :herald_categories, force: :cascade do |t|
    t.string :name, null: false
    t.string :slug, null: false
    t.text :description
    t.integer :position, default: 0
    t.timestamps
  end

  add_index :herald_categories, :slug, unique: true

  create_table :herald_post_categories, force: :cascade do |t|
    t.references :herald_post, null: false, foreign_key: true
    t.references :herald_category, null: false, foreign_key: true
    t.timestamps
  end

  add_index :herald_post_categories, [:herald_post_id, :herald_category_id], unique: true, name: "idx_herald_post_categories_unique"

  create_table :herald_tags, force: :cascade do |t|
    t.string :name, null: false
    t.string :slug, null: false
    t.timestamps
  end

  add_index :herald_tags, :name, unique: true
  add_index :herald_tags, :slug, unique: true

  create_table :herald_post_tags, force: :cascade do |t|
    t.references :herald_post, null: false, foreign_key: true
    t.references :herald_tag, null: false, foreign_key: true
    t.timestamps
  end

  add_index :herald_post_tags, [:herald_post_id, :herald_tag_id], unique: true, name: "idx_herald_post_tags_unique"

  # ActionText tables
  create_table :action_text_rich_texts, force: :cascade do |t|
    t.string :name, null: false
    t.text :body
    t.string :record_type, null: false
    t.bigint :record_id, null: false
    t.timestamps
    t.index [:record_type, :record_id, :name], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table :active_storage_blobs, force: :cascade do |t|
    t.string :key, null: false
    t.string :filename, null: false
    t.string :content_type
    t.text :metadata
    t.string :service_name, null: false
    t.bigint :byte_size, null: false
    t.string :checksum
    t.datetime :created_at, null: false
    t.index [:key], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table :active_storage_attachments, force: :cascade do |t|
    t.string :name, null: false
    t.string :record_type, null: false
    t.bigint :record_id, null: false
    t.bigint :blob_id, null: false
    t.datetime :created_at, null: false
    t.index [:blob_id], name: "index_active_storage_attachments_on_blob_id"
    t.index [:record_type, :record_id, :name, :blob_id], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table :active_storage_variant_records, force: :cascade do |t|
    t.bigint :blob_id, null: false
    t.string :variation_digest, null: false
    t.index [:blob_id, :variation_digest], name: "index_active_storage_variant_records_uniqueness", unique: true
  end
end
