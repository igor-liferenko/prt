#include <poppler-document.h>
#include <poppler-page.h>
#include <poppler-toc.h>
#include <iostream>

using namespace poppler;

std::string to_utf8(ustring x){
  if(x.length()){
    byte_array buf = x.to_utf8();
    return std::string(buf.data(), buf.size());
  } else {
    return std::string("null");
  }
}

int main(int argc, char* argv[]){
  if (argc < 2)
    throw std::runtime_error("Use pdf filename as parameter");
  document * doc = document::load_from_file(argv[1], "", "");
  if(!doc)
    throw std::runtime_error("Failed to read pdf file");
  for (int i = 0; i < atoi(argv[2]); i++) {
    page *p(doc->create_page(i));
    if (!p)
      throw std::runtime_error("Failed to create pagee");
    std::cout << to_utf8(p->label()) <<  std::endl;
  }
  return 0;
}
// g++ -std=c++11 getlabel.cpp $(pkg-config --cflags --libs poppler-cpp)
 https://github.com/lovasoa/pagelabels-py
./addpagelabels.py --delete file.pdf
./addpagelabels.py --startpage 1 --type 'roman lowercase' file.pdf
./addpagelabels.py --startpage 7 --type arabic file.pdf
/*   /Type /Catalog
  /PageLabels << /Nums [ 0 << /S /D >> ] >>
qpdf -qdf ../utf8.pdf utf8.qdf
fix-qdf foo.qdf >bar.qdf
qpdf bar.qdf bar.pdf
