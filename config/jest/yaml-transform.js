const yaml = require('js-yaml');
const fs = require('fs');
const crypto = require('crypto');
const THIS_FILE = fs.readFileSync(__filename);

module.exports = {
    process(src, path) {
        const obj = yaml.safeLoad(src);
        return `module.exports = ${JSON.stringify(obj)}`;
    },

    getCacheKey(fileData) {
        return crypto.createHash('md5')
            .update(fileData)
            .update('\0', 'utf8')
            .update(THIS_FILE)
            .digest('hex');
    },
}
