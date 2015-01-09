BEGIN {
  printHeader();

  moduleCount = 1;
  moduleCache[filenameModule(filename)] = ""
  tree[moduleCount] = filenameModule(filename) ":" processFile(filename);

  for (i = 1; i <= moduleCount; i++) {
    split(tree[i], fileAndImports, ":")
    fileModule = fileAndImports[1];

    split(fileAndImports[2], modules, ",");

    for (j = 1; j <= length(modules); j++) {
      module = modules[j]

      if (!(module in moduleCache)) {
        moduleCache[module] = ""
        tree[moduleCount++] = module ":" processFile(moduleFilename(module))
      }

      print "\t\"" fileModule "\" -> \"" module "\" [arrowhead=\"open\", arrowtail=\"none\"]"
    }

    if (fileModule != "") {
      print "\t\"" fileModule "\" [shape=box]"
    }
  }

  printFooter();
}

function printHeader() {
  print "strict digraph elm_dependencies {"
  print "\tgraph[overlap=false, splines=true]"
}

function printFooter() {
  print "}"
}

function processFile(filename) {
  imports = ""

  if (system( "[ -f " filename " ] ") == 0) {
    "awk 'BEGIN { ORS=\",\" } $0 ~ /^import\\s+/ { print $2 }' \"" filename "\" | sed 's/,$//'" | getline imports
  }

  return imports
}

function moduleFilename(module) {
  gsub(/\./, "/", module);

  return module ".elm"
}

function filenameModule(filename) {
  split(filename, parts, ".")

  return parts[1];
}
