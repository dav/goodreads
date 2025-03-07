require 'spec_helper'

describe 'Client' do
  before :each do
    Goodreads.configure('SECRET_KEY')
    @client = Goodreads::Client.new
  end
  
  it 'should return a book found by isbn' do
    stub_with_key_get('/book/isbn', {:isbn => '0307463745'}, 'book.xml')
    
    proc { @book = @client.book_by_isbn('0307463745') }.should_not raise_error
    @book.respond_to?(:id).should == true
    @book.respond_to?(:title).should == true
  end
  
  it 'should return a book found by goodreads id' do
    stub_with_key_get('/book/show', {:id => '6732019'}, 'book.xml')
    proc { @client.book('6732019') }.should_not raise_error
  end
  
  it 'should return a book found by title' do
    stub_with_key_get('/book/title', {:title => 'Rework'}, 'book.xml')
    proc { @client.book_by_title('Rework') }.should_not raise_error
  end
  
  it 'should raise Goodreads::NotFound if book was not found' do
    stub_request(:get, "http://www.goodreads.com/book/isbn?format=xml&isbn=123456789&key=SECRET_KEY").
      to_return(:status => 404, :body => "", :headers => {})
         
    proc { @client.book_by_isbn('123456789') }.should raise_error Goodreads::NotFound
  end
  
  it 'should return recent reviews' do
    stub_with_key_get('/review/recent_reviews', {}, 'recent_reviews.xml')
    
    proc { @reviews = @client.recent_reviews }.should_not raise_error
    @reviews.should be_an_instance_of Array
    @reviews.size.should_not == 0
    @reviews.each do |r|
      r.respond_to?(:id).should == true
    end
  end
  
  it 'should return recent reviews with clean reviews' do
    stub_with_key_get('/review/recent_reviews', {}, 'recent_reviews.xml')
    
    proc { @reviews = @client.recent_reviews(:skip_cropped => true) }.should_not raise_error
    @reviews.should be_an_instance_of Array
    @reviews.size.should_not == 0
    @reviews.each do |r|
      r.respond_to?(:id).should == true
    end
  end
  
  it 'should return single review details' do
    stub_with_key_get('/review/show', {:id => '166204831'}, 'review.xml')
    
    proc { @review = @client.review('166204831') }.should_not raise_error
    @review.should be_an_instance_of Hashie::Mash
    @review.respond_to?(:id).should == true
    @review.id.should == '166204831'
  end
  
  it 'should raise Goodreads::NotFound if review was not found' do
    stub_request(:get, "http://www.goodreads.com/review/show?format=xml&id=12345&key=SECRET_KEY").
      to_return(:status => 404, :body => "", :headers => {})

    proc { @client.review('12345') }.should raise_error Goodreads::NotFound
  end
  
  it 'should return author details' do
    stub_with_key_get('/author/show', {:id => '18541'}, 'author.xml')
    
    proc { @author = @client.author('18541') }.should_not raise_error
    @author.should be_an_instance_of Hashie::Mash
    @author.respond_to?(:id).should == true
    @author.id.should == '18541'
    @author.name.should == "Tim O'Reilly"
  end
  
  it 'should raise Goodreads::NotFound if author was not found' do
    stub_request(:get, "http://www.goodreads.com/author/show?format=xml&id=12345&key=SECRET_KEY").
      to_return(:status => 404, :body => "", :headers => {})
    
    proc { @client.author('12345') }.should raise_error Goodreads::NotFound
  end
  
  it 'should return user details' do
    stub_with_key_get('/user/show', {:id => '878044'}, 'user.xml')
    
    proc { @user = @client.user('878044') }.should_not raise_error
    @user.should be_an_instance_of Hashie::Mash
    @user.respond_to?(:id).should == true
    @user.id.should == '878044'
    @user.name.should == 'Jan'
    @user.user_name.should == 'janmt'
  end
  
  it 'should raise Goodreads::NotFound if user was not found' do
    stub_request(:get, "http://www.goodreads.com/user/show?format=xml&id=12345&key=SECRET_KEY").
      to_return(:status => 404, :body => "", :headers => {})
    
    proc { @client.user('12345') }.should raise_error Goodreads::NotFound
  end
  
  it 'should return book search results' do
    stub_with_key_get('/search/index', {:q => 'Rework'}, 'search_books_by_name.xml')
    
    proc { @search = @client.search_books('Rework') }.should_not raise_error
    @search.should be_an_instance_of Hashie::Mash
    @search.respond_to?(:query).should == true
    @search.respond_to?(:total_results).should == true
    @search.respond_to?(:results).should == true
    @search.results.respond_to?(:work).should == true
    @search.query.should == 'Rework'
    @search.results.work.size.should == 3
    @search.results.work.first.id.should == 6928276
  end
end
