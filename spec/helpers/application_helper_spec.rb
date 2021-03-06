require 'spec_helper'

describe ApplicationHelper do
  describe "when escaping HTML while preserving entities (cleanse)" do
    it "should preserve plain text" do
      cleanse("Allison to Lillia").should eq "Allison to Lillia"
    end

    it "should escape HTML" do
      cleanse("<Fiona>").should eq "&lt;Fiona&gt;"
    end

    it "should preserve HTML entities" do
      cleanse("Allison &amp; Lillia").should eq "Allison &amp; Lillia"
    end

    it "should handle text, HTML and entities together" do
      cleanse("&quot;<Allison> &amp; Lillia&quot;").should eq "&quot;&lt;Allison&gt; &amp; Lillia&quot;"
    end
  end

  describe "#tag_links_for" do
    it "renders tag links for the supplied model" do
      event = FactoryGirl.create(:event, tag_list: %w(b a))
      tag_links_for(event).should ==
        %(<a href="/events/tag/a" class="p-category">a</a>, ) +
        %(<a href="/events/tag/b" class="p-category">b</a>)
    end
  end

  describe "#format_description" do
    it "should autolink" do
      helper.format_description("foo http://mysite.com/~user bar").should eq \
        '<p>foo <a href="http://mysite.com/~user">http://mysite.com/~user</a> bar</p>'
    end

    it "should process Markdown links" do
      helper.format_description("[ClojureScript](https://github.com/clojure/clojurescript), the Clojure to JS compiler").should eq \
        '<p><a href="https://github.com/clojure/clojurescript">ClojureScript</a>, the Clojure to JS compiler</p>'
    end

    it "should process Markdown references" do
      helper.format_description("
[SocketStream][1], a phenomenally fast real-time web framework for Node.js

[1]: https://github.com/socketstream/socketstream
      ").should eq \
        '<p><a href="https://github.com/socketstream/socketstream">SocketStream</a>, a phenomenally fast real-time web framework for Node.js</p>'
    end
  end

  describe "the source code version date" do
    it "should come from git if possible" do
      ApplicationHelper.should_receive(:`).with(/git/).and_return("Tue Jul 29 01:22:49 2014 -0700")
      ApplicationHelper.source_code_version_raw.should match /Git timestamp: Tue Jul 29 01:22:49 2014 -0700/
    end

    it "should be blank if we can't ask git" do
      ApplicationHelper.should_receive(:`).with(/git/).and_raise(Errno::ENOENT)
      ApplicationHelper.source_code_version_raw.should == ""
    end
  end

  describe "#datestamp" do
    it "constructs a sentence describing the item's history" do
      event = FactoryGirl.create(:event, created_at: "2010-01-01", updated_at: "2010-01-02")
      event.create_source! title: "google", url: "http://google.com"
      event.source.stub id: 1
      datestamp(event).should ==
        %(This item was imported from <a href="/sources/1">google</a> <br />) +
        %(<strong>Friday, January 1, 2010 at midnight</strong> ) +
        %(and last updated <br /><strong>Saturday, January 2, 2010 at midnight</strong>.)
    end
  end
end
