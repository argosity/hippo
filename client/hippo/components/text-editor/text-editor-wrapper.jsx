import styled from 'styled-components';

const TextEditorWrapper = styled.div`
    flex: 1;
    min-height: 400px;
    margin: 0.8em;
    p:not(.grommetux-paragraph) {
        max-width: inherit;
        margin-left: 0;
        margin-top: 0;
        margin-bottom: 0;
    }

    button:not(.grommetux-button) {
        min-width: inherit;
        padding: 0;
        border: 0;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    header {
        .active {
            border-bottom: 2px solid $focus-border-color;
        }
        button + button {
            margin-left: 0.5rem;
        }
    }

`;

export default TextEditorWrapper;
