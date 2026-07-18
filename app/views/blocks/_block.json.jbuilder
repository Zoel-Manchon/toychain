json.extract! block, :id, :block_index, :data, :previous_hash, :block_hash, :nonce, :mined_at, :created_at, :updated_at
json.url block_url(block, format: :json)
