import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ApolloProvider } from '@apollo/client/react'
import { notification } from 'antd'
import { apolloClient } from './lib/apollo'
import { LanguageProvider } from './lib/i18n'
import 'antd/dist/reset.css'
import './index.css'
import App from './App.tsx'

notification.config({
  placement: 'topRight',
  top: 24,
  duration: 4,
})

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ApolloProvider client={apolloClient}>
      <LanguageProvider>
        <App />
      </LanguageProvider>
    </ApolloProvider>
  </StrictMode>,
)
