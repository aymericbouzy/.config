import 'zx/globals';

const {
  _: [_, script],
} = argv;

const mjsTemplate = `import 'zx/globals';`;
const binTemplate = `#!/usr/bin/env zx
import "../${script}.mjs";`;

const mjsPath = `${__dirname}/../${script}.mjs`;
const binPath = `${__dirname}/${script}`;

$`echo ${mjsTemplate} > ${mjsPath}
echo ${binTemplate} > ${binPath}
chmod +x ${binPath}
code ${mjsPath}`;
