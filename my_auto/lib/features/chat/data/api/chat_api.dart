/// GraphQL documents for the chat feature.
const String GET_CONVERSATIONS = r"""
query GetConversations($pagination: PaginationInput) {
  getConversations(pagination: $pagination) {
    payload {
      _id
      lastMessageText
      lastMessageSender
      lastMessageAt
      unread
      createdAt
      updatedAt
      participants {
        _id
        name
        phone
      }
      part {
        _id
        name
        images
      }
    }
    totalDocs
    page
    limit
    totalPages
    hasNextPage
    hasPrevPage
    nextPage
    prevPage
  }
}
""";

const String GET_MESSAGES = r"""
query GetMessages($conversationId: ObjectId!, $pagination: PaginationInput) {
  getMessages(conversationId: $conversationId, pagination: $pagination) {
    payload {
      _id
      text
      images
      readBy
      createdAt
      updatedAt
      replyTo
      replyToText
      replyToSenderName
      replyToSenderId
      voiceUrl
      voiceDurationMs
      sender {
        _id
        name
        phone
      }
    }
    totalDocs
    page
    limit
    totalPages
    hasNextPage
    hasPrevPage
    nextPage
    prevPage
  }
}
""";

const String CREATE_CONVERSATION = r"""
mutation CreateConversation($data: CreateConversationInput!) {
  createConversation(data: $data) {
    _id
    lastMessageText
    lastMessageAt
    participants {
      _id
      name
      phone
    }
    part {
      _id
      name
      images
    }
  }
}
""";

const String SEND_MESSAGE = r"""
mutation SendMessage($data: SendMessageInput!) {
  sendMessage(data: $data) {
    _id
    text
    images
    readBy
    createdAt
    replyTo
    replyToText
    replyToSenderName
    replyToSenderId
    voiceUrl
    voiceDurationMs
    sender {
      _id
      name
      phone
    }
  }
}
""";

const String MARK_AS_READ = r"""
mutation MarkAsRead($conversationId: ObjectId!) {
  markAsRead(conversationId: $conversationId) {
    _id
  }
}
""";

const String SET_TYPING = r"""
mutation SetTyping($conversationId: ObjectId!, $isTyping: Boolean!) {
  setTyping(conversationId: $conversationId, isTyping: $isTyping)
}
""";

const String DELETE_CONVERSATION_FOR_ME = r"""
mutation DeleteConversationForMe($conversationId: ObjectId!) {
  deleteConversationForMe(conversationId: $conversationId)
}
""";

const String DELETE_MESSAGE_FOR_ME = r"""
mutation DeleteMessageForMe($messageId: ObjectId!) {
  deleteMessageForMe(messageId: $messageId)
}
""";

const String UPDATE_MESSAGE = r"""
mutation UpdateMessage($data: UpdateMessageInput!) {
  updateMessage(data: $data) {
    _id
    text
    images
    readBy
    createdAt
    updatedAt
    sender {
      _id
      name
      phone
    }
  }
}
""";

const String MESSAGE_RECEIVED_SUB = r"""
subscription MessageReceived($conversationId: ObjectId!) {
  messageReceived(conversationId: $conversationId) {
    _id
    text
    images
    readBy
    createdAt
    replyTo
    replyToText
    replyToSenderName
    replyToSenderId
    voiceUrl
    voiceDurationMs
    sender {
      _id
      name
      phone
    }
  }
}
""";

const String TYPING_STATUS_SUB = r"""
subscription TypingStatus($conversationId: ObjectId!) {
  typingStatus(conversationId: $conversationId) {
    conversationId
    userId
    isTyping
  }
}
""";

const String CONVERSATION_UPDATED_SUB = r"""
subscription ConversationUpdated {
  conversationUpdated {
    _id
    lastMessageText
    lastMessageSender
    lastMessageAt
    unread
    participants {
      _id
      name
      phone
    }
    part {
      _id
      name
      images
    }
  }
}
""";

const String UNREAD_COUNT_CHANGED_SUB = r"""
subscription UnreadCountChanged {
  unreadCountChanged {
    conversationId
    userId
    unread
  }
}
""";
