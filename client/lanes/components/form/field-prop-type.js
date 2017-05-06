import { get } from 'lodash';

export default function FormFieldPropType(props) {
    const fieldName = 'name';
    const formPropName = 'formFields';
    if (!get(props, `${formPropName}.fields`)) {
        return new Error(`Missing form prop ${formPropName}`);
    }
    if (!props[fieldName]) {
        return new Error(`Missing field name identifier prop ${fieldName}`);
    }
    if (!props[formPropName].fields.get(props[fieldName])) {
        return new Error(`Form does not have a field named ${props[fieldName]}`);
    }
    return null;
}
