alias y=yarn

function yarn-link-list {
  ( ls -l node_modules ; ls -l node_modules/@* ) | grep ^l
}
