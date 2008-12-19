require File.dirname(__FILE__) + '/spec_helper'

class Book < YamlModel::Base
  fields :title, :author, :content
  data_dir File.dirname(__FILE__) + '/data'
end

def fn
  File.expand_path(File.dirname(__FILE__) + '/data/book.yml')
end

describe Book, '(setup)' do
  before(:each) do
    File.delete(fn) rescue ''
  end

  it "should return the data file path" do
    Book.data_file.should == fn
  end
  
  it "should create the data file if it doesn't yet exist" do
    File.exist?(Book.data_file).should == false
    Book.setup
    File.exist?(Book.data_file).should == true
  end
end

describe Book do
  before(:each) do
    File.delete(Book.data_file) rescue ''
    Book.setup
  end
  
  it "should find all books (empty list)" do
    Book.all.should == []
  end
  
  it "should create books" do
    pending "not implemented yet" do
      b = Book.create(:title => 'test', :content => 'important content', :author => 'fronx')
      b.should be_kind_of(Book)
    end
  end
end

describe Book, '(read)' do
  before(:each) do
    data = %Q{- 
  title: the book about some thing
  author: tim
  content: bla bli blub
- 
  title: book with structured content
  author: fronx
  content:
    chapter1: please read on in chapter 2.
    chapter2: and now, move back to the top, please.
}
    Book.stub!(:file_content).and_return(data)
  end
  
  it "should find all books" do
    books = Book.all
    books.size.should == 2
  end
  
  it "should have a title, author, and content" do
    b = Book.first
    b.title.should == 'the book about some thing'
    b.author.should == 'tim'
    b.content.should == 'bla bli blub'
  end

  it "can have structured content" do
    b = Book.last
    b.content.should == {
      'chapter1' => 'please read on in chapter 2.',
      'chapter2' => 'and now, move back to the top, please.'
    }
  end
end