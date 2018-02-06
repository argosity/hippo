import styled from 'styled-components';

const TextEditorWrapper = styled.div`
    flex: 1;
    min-height: 400px;
    margin: 0.8em;
    position: relative;
    display: flex;
    flex-direction: column;
    .ql-editor {
        flex: 1;
    }
`;

export default TextEditorWrapper;
