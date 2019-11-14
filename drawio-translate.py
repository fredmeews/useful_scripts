#!/opt/local/bin/python

"""
Translate text in drawio docs (in uncompressed xml) to another language using Google Translate.

"""
import codecs
import time
import sys

from xml.dom.minidom import *
from googletrans import Translator
from HTMLParser import HTMLParser

THROTTLE=2
SRC_LANG="en"
DEST_LANG="es"
DEBUG=1

class GoogleTranslate(Translator):
    def translate(self, text):
        time.sleep(THROTTLE)
        return super(GoogleTranslate, self).translate(text, DEST_LANG, SRC_LANG)

translator = GoogleTranslate()


class TranslateHTML(HTMLParser):
    translatedText = ""
    
    def handle_data(self, data):
        translation = translator.translate(data)
#        print "==>", unicode(translation.text)
        self.translatedText += translation.text

    def handle_starttag(self, tag, attrs):
        self.translatedText += self.get_starttag_text()

    def handle_endtag(self, tag):
        self.translatedText += "</" + tag + ">"

    def handle_starttag(self, tag, attrs):
        self.translatedText += self.get_starttag_text()

    def handle_endtag(self, tag):
        self.translatedText += "</" + tag + ">"


        

# ----------------------------------------------------------------------------
# -- Main
# ----------------------------------------------------------------------------
if (len(sys.argv) < 2):
    print "Usage:", sys.argv[0], "src_diag.drawio dest_diag.drawio"
    quit()
else:
    SRC_DIAG=sys.argv[1]
    DEST_DIAG=sys.argv[2]
    print "Translating", SRC_DIAG, "from", SRC_LANG, "to", DEST_LANG

doc = parse(SRC_DIAG)
nodes = doc.getElementsByTagName("mxCell")

for node in nodes:
    if node.hasAttribute("style"):
        style = node.getAttribute("style")
        text = node.getAttribute("value")
        parser = TranslateHTML()

        if (style and "html=1" in style and text):
            print "1: ",  text

            if ("<font" in text):
                parser.feed(text)

            try:
                # TODO - parse text out of font tags before translating & paste back together later
                if parser.translatedText:
                    translation = parser.translatedText
                else:
                    translation =  translator.translate(text).text

                print "2: ", translation, "\n"
                node.setAttribute("value", translation)
                
            except ValueError as e:
                print "^ could not translate", e
                
doc.writexml (
    codecs.open(DEST_DIAG, 'w', encoding='utf-8'),
    indent="  ",
    addindent="  ",
    newl=''
)

print "Translated diagram: " , DEST_DIAG
 

            
