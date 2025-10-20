function initResource() {
  var currentData = {};
  var editor = undefined;
  function initEditor(data) {
    editor = new EditorJS({
      minHeight: 30,
      holder: 'element',
      placeholder: placeholder,
      data: data,
      tools: {
        header: Header,
        quote: Quote,
        list: {
          class: NestedList,
          inlineToolbar: true,
        },
        embed: {
          class: Embed,
          inlineToolbar: false,
          config: {
            services: {
              youtube: true,
            }
          }
        },
        delimiter: Delimiter,
        image: {
          class: ImageTool,
          config: {
            uploader: {
              /**
               * Upload file to the server and return an uploaded image data
               * @param {File} file - file selected from the device or pasted by drag-n-drop
               * @return {Promise.<{success, file: {url}}>}
               */
              async uploadByFile(file){
                // your own uploading logic here
                let response = await getSignedURL(file)
                let completed = await uploadFile(file, response)
                response["file"]["url"] = response["file"]["get_url"]
                return response
              },
            }
          }
        },
        attaches: {
          class: AttachesTool,
          config: {
            uploader: {
              /**
               * Upload file to the server and return an uploaded image data
               * @param {File} file - file selected from the device or pasted by drag-n-drop
               * @return {Promise.<{success, file: {url}}>}
               */
              async uploadByFile(file){
                // your own uploading logic here
                let response = await getSignedURL(file)
                let completed = await uploadFile(file, response)
                return response
              },
            }
          }
        }
      },
      onChange: function (value) {
        value.saver.save().then(function(data) {
          app.saveData(data)
        })
      }
    });
  }

  Vue.component('v-node', {
    template: '#v-node',
    delimiters: ['[[', ']]'],
    props: {
      chapter: Object,
      currentItem: Object,
    },
    methods: {
      changeChapter (chapter) {
        app.chapter = chapter
        editor.destroy()
        initEditor(app.chapter.content)
      },
      move (item, upOrDown) {
        app.findParent(app.chapters, item.id)
        const oldIndex = app.parent.findIndex(a => a.id === item.id)
        // check if new index exists
        if ((oldIndex + 1 === app.parent.length && upOrDown === 1) || (oldIndex === 0 && upOrDown === -1)) { return }
        app.parent.splice(oldIndex, 1)
        app.parent.splice(oldIndex + upOrDown, 0, item)
      },
      add (item, contentType) {
        app.findParent(app.chapters, item.id)
        const index = app.parent.findIndex(a => a.id === item.id)
        const newItem = {
          id: app.getRandomString(),
          type: contentType,
          name: newItemText,
          content: { blocks: [] },
          parent_chapter: null,
          children: []
        }
        if (contentType === 1) {
          newItem.children = [{
            id: app.getRandomString(),
            type: 0,
            name: newItemText,
            content: {},
            children: [],
            parent_chapter: -1
          }]
        }
        app.parent.splice(index + 1, 0, newItem)
      },
      deleteItem (item) {
        app.findParent(app.chapters, item.id)
        if (app.parent.length === 1) {
          // can't delete last item
          return
        }
        const indexAt = app.parent.findIndex(a => a.id === item.id)
        app.parent.splice(indexAt, 1)
      },
    }
  });

  let chapters_from_html = JSON.parse(document.getElementById('chapters').textContent)

  console.log(chapters_from_html)
  var app = new Vue({
    el: '#app',
    delimiters: ['[[', ']]'],
    data: function () {
      return {
        chapters: [],
        chapter: { content: [] },
        parent: undefined
      }
    },
    mounted () {
      this.chapters = chapters_from_html
      if (!this.chapters.length) {
        this.chapters = [{
          id: this.getRandomString(),
          type: 0,
          name: newItemText,
          content: { blocks: [] },
          parent_chapter: null,
          children: []
        }]
      }
      this.chapter = this.chapters[0]
      initEditor(this.chapter.content)
    },
    methods: {
      saveData (data) {
        this.chapter.content = data
      },
      findParent (source, id) {
        // https://stackoverflow.com/a/23460304
        if (id === undefined) {
          this.parent = null
          return
        }
        let key
        for (key in source) {
          const item = source[key]
          if (item.id === id) {
            this.parent = source
            return
          }
          if (item.children) {
            const subresult = this.findParent(item.children, id)
            if (subresult) {
              this.parent = item.children
              return
            }
          }
        }
        return null
      },
      addQuestion () {
        const uniqueId = this.getRandomString()
        this.chapter.content.blocks.push({
          'content': "",
          'items': [{ 'id': uniqueId, 'text': '' }],
          'type': 'question',
          'answer': uniqueId
        })
      },
      addOption (items) {
        items.push({ 'text': '', 'id': this.getRandomString() })
      },
      removeQuestion (index) {
        this.chapter.content.blocks.splice(index, 1)
      },
      removeOption (indexQuestion, indexOption) {
        this.chapter.content.blocks[indexQuestion].items.splice(indexOption, 1)
      },
      getRandomString () {
        // from https://stackoverflow.com/a/6860916
        return "temp-" + (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)
      }
    }
  })
}
// FOR RESOURCE/COURSE
$(document).on('change', "#id_course", function() {
  if (this.checked == true){
    $("#div_id_on_day").parent().removeClass("d-none")
    $("#div_id_remove_on_complete").parent().parent().removeClass("d-none")
  } else {
    $("#div_id_on_day").parent().addClass("d-none")
    $("#div_id_remove_on_complete").parent().parent().addClass("d-none")
  }
})
