require 'spec_helper'

RSpec.describe HashKit::Helper do
  describe '#symbolize' do

    context 'when a single layer hash with string keys is specified' do
      let(:hash) { { 'key1' => 'value1', 'key2' => 'value2' } }

      it 'should return a hash with symbolized keys' do
        new_hash = subject.symbolize(hash)
        expect(new_hash.has_key?('key1')).to be_falsey
        expect(new_hash.has_key?('key2')).to be_falsey
        expect(new_hash.has_key?(:key1)).to be_truthy
        expect(new_hash.has_key?(:key2)).to be_truthy
      end
    end

    context 'when a single layer hash with symbol keys is specified' do
      let(:hash) { { :key1 => 'value1', :key2 => 'value2' } }

      it 'should return a hash with symbolized keys' do
        new_hash = subject.symbolize(hash)
        expect(new_hash.has_key?(:key1)).to be_truthy
        expect(new_hash.has_key?(:key2)).to be_truthy
      end
    end

    context 'when a hash with a nested hash is specified' do
      let(:hash) { { 'key1' => 'value1', 'key2' => 'value2', 'key3' => { 'key4' => 'value4' } } }

      it 'should return a hash with symbolized keys' do
        new_hash = subject.symbolize(hash)
        expect(new_hash.has_key?('key1')).to be_falsey
        expect(new_hash.has_key?('key2')).to be_falsey
        expect(new_hash.has_key?('key3')).to be_falsey
        expect(new_hash.has_key?(:key1)).to be_truthy
        expect(new_hash.has_key?(:key2)).to be_truthy
        expect(new_hash.has_key?(:key3)).to be_truthy

        expect(new_hash[:key3].has_key?('key4')).to be_falsey
        expect(new_hash[:key3].has_key?(:key4)).to be_truthy
      end
    end

    context 'when a hash with an array of nested hashes is specified' do
      let(:hash) { { 'key1' => 'value1', 'key2' => 'value2', 'key3' => [{ 'key4' => 'value4' }, { 'key4' => 'value4' }]} }

      it 'should return a hash with symbolized keys' do
        new_hash = subject.symbolize(hash)
        expect(new_hash.has_key?('key1')).to be_falsey
        expect(new_hash.has_key?('key2')).to be_falsey
        expect(new_hash.has_key?('key3')).to be_falsey
        expect(new_hash.has_key?(:key1)).to be_truthy
        expect(new_hash.has_key?(:key2)).to be_truthy
        expect(new_hash.has_key?(:key3)).to be_truthy

        expect(new_hash[:key3][0].has_key?('key4')).to be_falsey
        expect(new_hash[:key3][0].has_key?(:key4)).to be_truthy
        expect(new_hash[:key3][1].has_key?('key4')).to be_falsey
        expect(new_hash[:key3][1].has_key?(:key4)).to be_truthy
      end
    end

  end

  describe '#stringify' do

    context 'when a single layer hash with symbol keys is specified' do
      let(:hash) { { :key1 => 'value1', :key2 => 'value2' } }

      it 'should return a hash with stringified keys' do
        new_hash = subject.stringify(hash)
        expect(new_hash.has_key?('key1')).to be true
        expect(new_hash.has_key?('key2')).to be true
        expect(new_hash.has_key?(:key1)).to be false
        expect(new_hash.has_key?(:key2)).to be false
      end
    end

    context 'when a single layer hash with string keys is specified' do
      let(:hash) { { 'key1' => 'value1', :'key2' => 'value2' } }

      it 'should return a hash with stringified keys' do
        new_hash = subject.stringify(hash)
        expect(new_hash.has_key?('key1')).to be true
        expect(new_hash.has_key?('key2')).to be true
      end
    end

    context 'when a hash with a nested hash is specified' do
      let(:hash) { { :key1 => 'value1', :key2 => 'value2', :key3 => { :key4 => 'value4' } } }

      it 'should return a hash with stringified keys' do
        new_hash = subject.stringify(hash)
        expect(new_hash.has_key?('key1')).to be true
        expect(new_hash.has_key?('key2')).to be true
        expect(new_hash.has_key?('key3')).to be true
        expect(new_hash.has_key?(:key1)).to be false
        expect(new_hash.has_key?(:key2)).to be false
        expect(new_hash.has_key?(:key3)).to be false

        expect(new_hash['key3'].has_key?('key4')).to be true
        expect(new_hash['key3'].has_key?(:key4)).to be false
      end
    end

    context 'when a hash with an array of nested hashes is specified' do
      let(:hash) { { :key1 => 'value1', :key2 => 'value2', :key3 => [{ :key4 => 'value4' }, { :key4 => 'value4' }]} }

      it 'should return a hash with stringified keys' do
        new_hash = subject.stringify(hash)
        expect(new_hash.has_key?('key1')).to be true
        expect(new_hash.has_key?('key2')).to be true
        expect(new_hash.has_key?('key3')).to be true
        expect(new_hash.has_key?(:key1)).to be false
        expect(new_hash.has_key?(:key2)).to be false
        expect(new_hash.has_key?(:key3)).to be false

        expect(new_hash['key3'][0].has_key?('key4')).to be true
        expect(new_hash['key3'][0].has_key?(:key4)).to be false
        expect(new_hash['key3'][1].has_key?('key4')).to be true
        expect(new_hash['key3'][1].has_key?(:key4)).to be false
      end
    end

  end

  describe '#to_hash' do

    let(:key1) do
      { key1: 'value1' }
    end

    let(:key2) do
      { key2: 'value2' }
    end

    let(:child_entity) do
      TestEntity.new.tap do |entity|
        entity.text = 'abc'
        entity.numeric = 5
        entity.time = Time.now
      end
    end

    let(:parent_entity) do
      TestEntity.new.tap do |entity|
        entity.text = 'abc'
        entity.numeric = 5
        entity.time = Time.now
        entity.hash = key1
        entity.hash_array = [key1, key2]
        entity.entity = child_entity
        entity.entity_array = [child_entity, child_entity]
      end
    end
   
    context 'entity to convert is nil' do
      it 'returns nil' do
        expect(subject.to_hash(nil)).to eq nil
      end
    end

    context 'single layer entity' do
      it 'should create a hash' do
        hash = subject.to_hash(child_entity)
        expect(hash[:text]).to eq(child_entity.text)
        expect(hash[:numeric]).to eq(child_entity.numeric)
        expect(hash[:time]).to eq(child_entity.time)
      end
    end

    context 'multi layer entity' do
     it 'should create a hash' do
       hash = subject.to_hash(parent_entity)
       expect(hash[:text]).to eq(parent_entity.text)
       expect(hash[:numeric]).to eq(parent_entity.numeric)
       expect(hash[:time]).to eq(parent_entity.time)
       expect(hash[:hash].has_key?(:key1)).to be true
       expect(hash[:hash_array].length).to eq(2)
       expect(hash[:entity][:text]).to eq(child_entity.text)
       expect(hash[:entity][:numeric]).to eq(child_entity.numeric)
       expect(hash[:entity][:time]).to eq(child_entity.time)
       expect(hash[:entity_array].length).to eq(2)
       expect(hash[:entity_array][0][:text]).to eq(child_entity.text)
       expect(hash[:entity_array][1][:text]).to eq(child_entity.text)
     end
    end

    [
      "string"    ,  
      101         ,
      1.01        ,
      Time.now    ,
      Date.today  ,
      DateTime.now,
      nil         ,
      true        ,
      false
    ].each do |value|
      context "when text is set to '#{value}'" do
        let(:child_entity) do
          TestEntity.new.tap do |entity|
            entity.text = value
          end
        end

        it 'creates a hash with the expected value' do
          hash = subject.to_hash(child_entity)
          expect(hash[:text]).to eq(value)
        end
      end
    end

    context 'when one value is nil' do
      let(:child_entity) do
        TestEntity.new.tap do |entity|
          entity.text = ''
          entity.numeric = nil
        end
      end

      it 'creates a hash with the nil value' do
        hash = subject.to_hash(child_entity)
        expect(hash[:text   ]).to eq('')
        expect(hash[:numeric]).to eq(nil)
      end
    end
  end

  describe '#from_hash' do

    let(:child_hash) do
      {
          text: 'abc',
          numeric: 5,
          time: Time.now,
          invalid_key: 5,
          bool: true
      }
    end

    let(:parent_hash) do
      {
          text: 'abc',
          numeric: 5,
          time: Time.now,
          entity: child_hash,
          entity_array: [child_hash, child_hash],
          invalid_key: 5,
          bool: true
      }
    end

    let(:string_hash) do
      {
          'text' => 'abc',
          'numeric' => 5,
          'time' => Time.now,
          'invalid_key' => 5,
          'bool' => true
      }
    end

    let(:transforms) do
      [
        HashKit::TransformItem.new.tap do |entity|
          entity.key = :entity
          entity.klass = TestEntity
        end,
        HashKit::TransformItem.new.tap do |entity|
          entity.key = :entity_array
          entity.klass = TestEntity
        end
      ]
    end

    context 'nil hash' do
      it 'should return a new class instance' do
        obj = subject.from_hash(nil, TestEntity)
        expect(obj).to be_a(TestEntity)
      end
    end

    context 'empty hash' do
      it 'should return a new class instance' do
        obj = subject.from_hash({}, TestEntity)
        expect(obj).to be_a(TestEntity)
      end
    end

    context 'simple hash' do
      context 'with symbol keys' do
        it 'should convert the hash to the expected class' do
          obj = subject.from_hash(child_hash, TestEntity)
          expect(obj).to be_a(TestEntity)
          expect(obj.text).to eq(child_hash[:text])
          expect(obj.numeric).to eq(child_hash[:numeric])
          expect(obj.time).to eq(child_hash[:time])
          expect(obj.bool).to eq(child_hash[:bool])
        end
      end

      context 'with string keys' do
        it 'should convert the hash to the expected class' do
          obj = subject.from_hash(string_hash, TestEntity)
          expect(obj).to be_a(TestEntity)
          expect(obj.text).to eq(string_hash['text'])
          expect(obj.numeric).to eq(string_hash['numeric'])
          expect(obj.time).to eq(string_hash['time'])
          expect(obj.bool).to eq(string_hash['bool'])
        end
      end
    end

    context 'complex hash' do
      it 'should convert the hash to the expected class' do
        obj = subject.from_hash(parent_hash, TestEntity, transforms)
        expect(obj).to be_a(TestEntity)
        expect(obj.text).to eq(parent_hash[:text])
        expect(obj.numeric).to eq(parent_hash[:numeric])
        expect(obj.time).to eq(parent_hash[:time])
        expect(obj.entity).to be_a(TestEntity)
        expect(obj.entity.text).to eq(parent_hash[:entity][:text])
        expect(obj.entity.numeric).to eq(parent_hash[:entity][:numeric])
        expect(obj.entity.time).to eq(parent_hash[:entity][:time])
        expect(obj.entity_array.length).to eq(2)
        expect(obj.entity_array[0]).to be_a(TestEntity)
        expect(obj.entity_array[1]).to be_a(TestEntity)
      end
    end
  end
end
