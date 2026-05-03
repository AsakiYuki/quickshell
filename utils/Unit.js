function diskSize(bytes) {
  if (bytes === 0) return '0 B';

  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));

  const value = bytes / Math.pow(1024, i);

  return value.toFixed(2).replace(/\.00$/, '') + ' ' + units[i];
}