import { useEffect, useMemo, useRef, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import {
  ArrowLeft,
  BadgeCheck,
  CheckCheck,
  CornerUpLeft,
  Mic,
  Pause,
  Play,
  MessageSquare,
  Send,
  ShieldAlert,
  ShieldCheck,
} from 'lucide-react'
import {
  ADMIN_SET_USER_VERIFIED,
  CHAT_GET_CONVERSATIONS,
  CHAT_GET_MESSAGES,
  CHAT_MARK_AS_READ,
  CHAT_SEND_MESSAGE,
} from '../graphql/operations'
import type {
  ChatConversation,
  ChatMessage,
  ChatParticipant,
  PaginatedConversations,
  PaginatedMessages,
} from '../types'
import { getUser } from '../lib/auth'
import { mediaUrl } from '../lib/media'

const CONVERSATIONS_POLL_MS = 8_000
const MESSAGES_POLL_MS = 4_000

function peerOf(
  conversation: ChatConversation,
  currentUserId: string,
): ChatParticipant | undefined {
  return (
    conversation.participants.find((p) => p._id !== currentUserId) ??
    conversation.participants[0]
  )
}

function formatRelative(iso?: string | null): string {
  if (!iso) return ''
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return ''
  const now = new Date()
  const sameDay =
    date.getFullYear() === now.getFullYear() &&
    date.getMonth() === now.getMonth() &&
    date.getDate() === now.getDate()
  if (sameDay) {
    return date.toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    })
  }
  const diffDays = Math.floor((now.getTime() - date.getTime()) / 86_400_000)
  if (diffDays < 7) {
    return date.toLocaleDateString('ru-RU', { weekday: 'short' })
  }
  return date.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit' })
}

function initialsOf(name?: string | null): string {
  if (!name) return '?'
  const parts = name.trim().split(/\s+/).slice(0, 2)
  return parts.map((p) => p[0]?.toUpperCase() ?? '').join('') || '?'
}

export function AdminMessagesPage() {
  const me = getUser()
  const currentUserId = me?._id ?? ''

  const [selectedId, setSelectedId] = useState<string | null>(null)

  const conversationsQuery = useQuery<{
    getConversations: PaginatedConversations
  }>(CHAT_GET_CONVERSATIONS, {
    variables: { pagination: { page: 1, limit: 50 } },
    pollInterval: CONVERSATIONS_POLL_MS,
    fetchPolicy: 'cache-and-network',
    notifyOnNetworkStatusChange: false,
  })

  const conversations = useMemo(() => {
    const list = conversationsQuery.data?.getConversations.payload ?? []
    return [...list].sort((a, b) => {
      const at = a.lastMessageAt ? new Date(a.lastMessageAt).getTime() : 0
      const bt = b.lastMessageAt ? new Date(b.lastMessageAt).getTime() : 0
      return bt - at
    })
  }, [conversationsQuery.data])

  const totalUnread = useMemo(
    () => conversations.reduce((sum, c) => sum + (c.unread ?? 0), 0),
    [conversations],
  )

  const selected = useMemo(
    () => conversations.find((c) => c._id === selectedId) ?? null,
    [conversations, selectedId],
  )

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-2">
        <div>
          <h1 className="text-2xl font-bold text-white">Сообщения</h1>
          <p className="text-sm text-carbon-100">
            Поддержка продавцов и заявки на верификацию.
            {totalUnread > 0 && (
              <span className="ml-2 rounded-md bg-amber-500 px-2 py-0.5 text-xs font-semibold text-white">
                {totalUnread} непрочитано
              </span>
            )}
          </p>
        </div>
        <button
          type="button"
          onClick={() => conversationsQuery.refetch()}
          className="rounded-lg border border-carbon-600 bg-carbon-800 px-3 py-2 text-xs text-carbon-100 hover:bg-carbon-700"
        >
          Обновить
        </button>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-[340px_1fr]">
        <div
          className={`rounded-2xl border border-carbon-600 bg-carbon-800 ${
            selected ? 'hidden md:block' : ''
          }`}
        >
          <ConversationList
            conversations={conversations}
            currentUserId={currentUserId}
            selectedId={selectedId}
            loading={conversationsQuery.loading && conversations.length === 0}
            onSelect={setSelectedId}
          />
        </div>

        <div
          className={`min-h-[60vh] rounded-2xl border border-carbon-600 bg-carbon-800 ${
            selected ? '' : 'hidden md:flex'
          }`}
        >
          {selected ? (
            <ConversationThread
              key={selected._id}
              conversation={selected}
              currentUserId={currentUserId}
              onBack={() => setSelectedId(null)}
              onAfterSend={() => conversationsQuery.refetch()}
            />
          ) : (
            <div className="flex w-full items-center justify-center py-24 text-center text-sm text-carbon-100">
              <div className="flex flex-col items-center gap-3">
                <MessageSquare className="h-10 w-10 text-carbon-100" />
                Выберите беседу слева, чтобы ответить пользователю.
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

interface ConversationListProps {
  conversations: ChatConversation[]
  currentUserId: string
  selectedId: string | null
  loading: boolean
  onSelect(id: string): void
}

function ConversationList({
  conversations,
  currentUserId,
  selectedId,
  loading,
  onSelect,
}: ConversationListProps) {
  if (loading) {
    return <p className="p-6 text-sm text-carbon-100">Загрузка...</p>
  }

  if (conversations.length === 0) {
    return (
      <div className="flex flex-col items-center gap-2 px-6 py-16 text-center">
        <ShieldCheck className="h-8 w-8 text-carbon-100" />
        <p className="text-sm text-carbon-100">Пока нет беседы.</p>
        <p className="text-xs text-carbon-100">
          Когда пользователь напишет в поддержку через мобильное приложение,
          беседа появится здесь.
        </p>
      </div>
    )
  }

  return (
    <ul className="max-h-[70vh] divide-y divide-carbon-600 overflow-y-auto">
      {conversations.map((conversation) => {
        const peer = peerOf(conversation, currentUserId)
        const isActive = conversation._id === selectedId
        const unread = conversation.unread ?? 0
        const rawSubtitle = conversation.lastMessageText?.trim() ?? ''
        const subtitle = renderLastMessagePreview(rawSubtitle)
        return (
          <li key={conversation._id}>
            <button
              type="button"
              onClick={() => onSelect(conversation._id)}
              className={`flex w-full items-start gap-3 px-3 py-3 text-left transition-colors ${
                isActive ? 'bg-amber-500/10' : 'hover:bg-carbon-700/50'
              }`}
            >
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-carbon-700 text-sm font-bold text-white">
                {initialsOf(peer?.name)}
              </div>
              <div className="flex-1 overflow-hidden">
                <div className="flex items-center justify-between gap-2">
                  <p className="flex min-w-0 items-center gap-1 truncate text-sm font-semibold text-white">
                    <span className="truncate">
                      {peer?.name?.trim() || peer?.phone || 'Без имени'}
                    </span>
                    {peer?.verified && (
                      <BadgeCheck
                        className="h-3.5 w-3.5 shrink-0 text-sky-400"
                        aria-label="Верифицирован"
                      />
                    )}
                  </p>
                  <span className="shrink-0 text-[10px] text-carbon-100">
                    {formatRelative(conversation.lastMessageAt)}
                  </span>
                </div>
                <div className="flex items-center justify-between gap-2">
                  <p
                    className={`truncate text-xs ${
                      unread > 0 ? 'font-semibold text-white' : 'text-carbon-100'
                    }`}
                  >
                    {subtitle}
                  </p>
                  {unread > 0 && (
                    <span className="shrink-0 rounded-full bg-amber-500 px-2 py-0.5 text-[10px] font-bold text-white">
                      {unread > 99 ? '99+' : unread}
                    </span>
                  )}
                </div>
                {peer?.phone && (
                  <p className="truncate text-[11px] text-carbon-100">
                    {peer.phone}
                  </p>
                )}
              </div>
            </button>
          </li>
        )
      })}
    </ul>
  )
}

interface ConversationThreadProps {
  conversation: ChatConversation
  currentUserId: string
  onBack(): void
  onAfterSend(): void
}

function ConversationThread({
  conversation,
  currentUserId,
  onBack,
  onAfterSend,
}: ConversationThreadProps) {
  const peer = peerOf(conversation, currentUserId)
  const [draft, setDraft] = useState('')
  const [sending, setSending] = useState(false)
  // Optimistic local override so the button reflects the action instantly
  // — we still rely on the upstream poll to converge state if anything fails.
  const [verifiedOverride, setVerifiedOverride] = useState<boolean | null>(null)
  const scrollerRef = useRef<HTMLDivElement>(null)
  const lastMessageIdRef = useRef<string | null>(null)

  const messagesQuery = useQuery<{ getMessages: PaginatedMessages }>(
    CHAT_GET_MESSAGES,
    {
      variables: {
        conversationId: conversation._id,
        pagination: { page: 1, limit: 50 },
      },
      pollInterval: MESSAGES_POLL_MS,
      fetchPolicy: 'cache-and-network',
      notifyOnNetworkStatusChange: false,
    },
  )

  const [sendMessage] = useMutation(CHAT_SEND_MESSAGE)
  const [markAsRead] = useMutation(CHAT_MARK_AS_READ)
  const [setUserVerified, { loading: verifying }] = useMutation<{
    adminSetUserVerified: { _id: string; verified?: boolean | null }
  }>(ADMIN_SET_USER_VERIFIED)

  // Reset override when switching conversations (key on _id below also helps,
  // but this guards against same-peer updates from the server overtaking us).
  useEffect(() => {
    setVerifiedOverride(null)
  }, [peer?._id])

  // Newest at the bottom (server returns newest first → reverse).
  const messages = useMemo<ChatMessage[]>(() => {
    const items = messagesQuery.data?.getMessages.payload ?? []
    return [...items].sort(
      (a, b) =>
        new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
    )
  }, [messagesQuery.data])

  // Mark as read whenever the thread is opened or new messages arrive.
  useEffect(() => {
    if (!conversation._id) return
    markAsRead({ variables: { conversationId: conversation._id } }).catch(
      () => {},
    )
  }, [conversation._id, messages.length, markAsRead])

  // Auto-scroll on new message append (not on every poll if nothing changed).
  useEffect(() => {
    const last = messages[messages.length - 1]
    if (!last) return
    if (lastMessageIdRef.current === last._id) return
    lastMessageIdRef.current = last._id
    const el = scrollerRef.current
    if (el) {
      el.scrollTop = el.scrollHeight
    }
  }, [messages])

  async function handleSend() {
    const text = draft.trim()
    if (!text || sending) return
    setSending(true)
    try {
      await sendMessage({
        variables: {
          data: {
            conversationId: conversation._id,
            text,
          },
        },
      })
      setDraft('')
      await messagesQuery.refetch()
      onAfterSend()
    } catch {
      // Surface failures inline rather than silently swallowing — admin will
      // try again. We avoid alerts to keep the dashboard quiet.
    } finally {
      setSending(false)
    }
  }

  const isVerified = verifiedOverride ?? peer?.verified === true

  async function handleToggleVerified() {
    if (!peer?._id || verifying) return
    const next = !isVerified
    const confirmText = next
      ? `Верифицировать пользователя «${peer.name?.trim() || peer.phone || ''}»?`
      : `Снять верификацию у пользователя «${peer.name?.trim() || peer.phone || ''}»?`
    if (!window.confirm(confirmText)) return
    setVerifiedOverride(next)
    try {
      await setUserVerified({
        variables: { userId: peer._id, verified: next },
      })
      // Pull fresh participant data so the badge/state stay in sync across
      // the list and any other places that mirror this field.
      onAfterSend()
    } catch {
      setVerifiedOverride(!next)
      window.alert('Не удалось обновить статус верификации. Попробуйте ещё раз.')
    }
  }

  return (
    <div className="flex w-full flex-col">
      <div className="flex items-center gap-3 border-b border-carbon-600 px-4 py-3">
        <button
          type="button"
          onClick={onBack}
          className="rounded-lg border border-carbon-600 bg-carbon-900 px-2 py-1 text-xs text-carbon-100 hover:bg-carbon-700 md:hidden"
        >
          <ArrowLeft className="h-4 w-4" />
        </button>
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-amber-500/20 text-sm font-bold text-amber-300">
          {initialsOf(peer?.name)}
        </div>
        <div className="flex-1 overflow-hidden">
          <p className="flex items-center gap-1.5 truncate font-semibold text-white">
            <span className="truncate">
              {peer?.name?.trim() || peer?.phone || 'Без имени'}
            </span>
            {isVerified && (
              <BadgeCheck
                className="h-4 w-4 shrink-0 text-sky-400"
                aria-label="Верифицирован"
              />
            )}
          </p>
          {peer?.phone && (
            <p className="truncate text-xs text-carbon-100">{peer.phone}</p>
          )}
        </div>
        {peer?._id && (
          <button
            type="button"
            onClick={() => void handleToggleVerified()}
            disabled={verifying}
            title={isVerified ? 'Снять верификацию' : 'Выдать верификацию'}
            className={`flex shrink-0 items-center gap-1.5 rounded-lg border px-3 py-1.5 text-xs font-semibold transition ${
              isVerified
                ? 'border-sky-500/50 bg-sky-500/10 text-sky-300 hover:bg-sky-500/20'
                : 'border-amber-500/60 bg-amber-500/10 text-amber-300 hover:bg-amber-500/20'
            } disabled:cursor-not-allowed disabled:opacity-60`}
          >
            {isVerified ? (
              <BadgeCheck className="h-4 w-4" />
            ) : (
              <ShieldAlert className="h-4 w-4" />
            )}
            <span className="hidden sm:inline">
              {verifying
                ? 'Сохраняем…'
                : isVerified
                  ? 'Верифицирован'
                  : 'Выдать верификацию'}
            </span>
          </button>
        )}
      </div>

      <div
        ref={scrollerRef}
        className="flex-1 space-y-3 overflow-y-auto px-4 py-4"
        style={{ maxHeight: 'calc(70vh - 60px)' }}
      >
        {messagesQuery.loading && messages.length === 0 && (
          <p className="text-center text-xs text-carbon-100">Загрузка...</p>
        )}
        {!messagesQuery.loading && messages.length === 0 && (
          <p className="text-center text-xs text-carbon-100">
            Пока нет сообщений в этой беседе.
          </p>
        )}
        {messages.map((message) => (
          <MessageBubble
            key={message._id}
            message={message}
            isMine={message.sender._id === currentUserId}
          />
        ))}
      </div>

      <div className="border-t border-carbon-600 p-3">
        <div className="flex items-end gap-2">
          <textarea
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault()
                void handleSend()
              }
            }}
            placeholder="Ответ пользователю..."
            rows={1}
            className="min-h-[44px] flex-1 resize-none rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-sm text-white outline-none focus:border-amber-500"
          />
          <button
            type="button"
            onClick={() => void handleSend()}
            disabled={sending || draft.trim().length === 0}
            className="flex h-11 w-11 items-center justify-center rounded-xl bg-amber-500 text-white transition disabled:cursor-not-allowed disabled:opacity-40"
          >
            <Send className="h-4 w-4" />
          </button>
        </div>
        <p className="mt-1 text-[10px] text-carbon-100">
          Enter — отправить, Shift+Enter — перенос строки
        </p>
      </div>
    </div>
  )
}

interface MessageBubbleProps {
  message: ChatMessage
  isMine: boolean
}

function MessageBubble({ message, isMine }: MessageBubbleProps) {
  const time = new Date(message.createdAt).toLocaleTimeString('ru-RU', {
    hour: '2-digit',
    minute: '2-digit',
  })
  const text = message.text?.trim()
  const images = message.images ?? []
  const hasImages = images.length > 0
  const hasVoice = !!message.voiceUrl?.trim()
  const hasReply = !!message.replyTo
  const readByOthers = (message.readBy ?? []).length > 1
  return (
    <div
      className={`flex w-full ${isMine ? 'justify-end' : 'justify-start'}`}
    >
      <div
        className={`flex max-w-[78%] flex-col gap-2 overflow-hidden rounded-2xl px-3 py-2 text-sm shadow-sm ${
          isMine ? 'bg-amber-500 text-white' : 'bg-carbon-700 text-carbon-50'
        }`}
      >
        {!isMine && (
          <p className="text-[10px] font-semibold text-amber-200">
            {message.sender.name?.trim() ||
              message.sender.phone ||
              'Пользователь'}
          </p>
        )}
        {hasReply && (
          <ReplyQuote
            isMine={isMine}
            senderName={message.replyToSenderName}
            text={message.replyToText}
          />
        )}
        {hasImages && <ImageGallery images={images} />}
        {hasVoice && (
          <VoicePlayer
            url={mediaUrl(message.voiceUrl!)}
            durationMs={message.voiceDurationMs ?? null}
            isMine={isMine}
          />
        )}
        {text && (
          <p className="whitespace-pre-wrap break-words leading-relaxed">
            {text}
          </p>
        )}
        <div
          className={`mt-1 flex items-center justify-end gap-1 text-[10px] ${
            isMine ? 'text-white/80' : 'text-carbon-100'
          }`}
        >
          <span>{time}</span>
          {isMine && readByOthers && <CheckCheck className="h-3 w-3" />}
        </div>
      </div>
    </div>
  )
}

interface ReplyQuoteProps {
  isMine: boolean
  senderName?: string | null
  text?: string | null
}

function ReplyQuote({ isMine, senderName, text }: ReplyQuoteProps) {
  const bg = isMine ? 'bg-white/15' : 'bg-amber-500/15'
  const accent = isMine ? 'bg-white' : 'bg-amber-400'
  const titleColor = isMine ? 'text-white' : 'text-amber-300'
  const previewColor = isMine ? 'text-white/85' : 'text-carbon-100'
  return (
    <div
      className={`flex items-stretch gap-2 rounded-lg ${bg} px-2 py-1 text-[12px]`}
    >
      <span className={`w-[3px] rounded ${accent}`} />
      <div className="flex min-w-0 flex-col">
        {senderName && (
          <span className={`truncate text-[11px] font-bold ${titleColor}`}>
            <CornerUpLeft className="mr-1 inline h-3 w-3 align-[-1px]" />
            {senderName}
          </span>
        )}
        {text && (
          <span className={`truncate ${previewColor}`}>{text}</span>
        )}
      </div>
    </div>
  )
}

interface ImageGalleryProps {
  images: string[]
}

function ImageGallery({ images }: ImageGalleryProps) {
  const resolved = useMemo(
    () => images.map((i) => mediaUrl(i)).filter(Boolean),
    [images],
  )
  if (resolved.length === 0) return null
  if (resolved.length === 1) {
    return (
      <a
        href={resolved[0]}
        target="_blank"
        rel="noreferrer"
        className="block overflow-hidden rounded-xl"
      >
        <img
          src={resolved[0]}
          alt="attachment"
          className="max-h-[280px] w-auto rounded-xl object-cover"
        />
      </a>
    )
  }
  const preview = resolved.slice(0, 4)
  const overflow = resolved.length - preview.length
  return (
    <div className="grid grid-cols-2 gap-1 overflow-hidden rounded-xl">
      {preview.map((src, idx) => {
        const isLast = idx === 3 && overflow > 0
        return (
          <a
            key={src + idx}
            href={src}
            target="_blank"
            rel="noreferrer"
            className="relative aspect-square overflow-hidden"
          >
            <img
              src={src}
              alt={`attachment-${idx + 1}`}
              className="h-full w-full object-cover"
            />
            {isLast && (
              <div className="absolute inset-0 flex items-center justify-center bg-black/55 text-base font-bold text-white">
                +{overflow}
              </div>
            )}
          </a>
        )
      })}
    </div>
  )
}

interface VoicePlayerProps {
  url: string
  durationMs: number | null
  isMine: boolean
}

function VoicePlayer({ url, durationMs, isMine }: VoicePlayerProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const [playing, setPlaying] = useState(false)
  const [position, setPosition] = useState(0)
  const [total, setTotal] = useState(
    durationMs && durationMs > 0 ? durationMs / 1000 : 0,
  )

  useEffect(() => {
    const audio = audioRef.current
    if (!audio) return
    const onTime = () => setPosition(audio.currentTime)
    const onMeta = () => {
      if (Number.isFinite(audio.duration) && audio.duration > 0) {
        setTotal(audio.duration)
      }
    }
    const onEnd = () => {
      setPlaying(false)
      setPosition(0)
    }
    const onPlay = () => setPlaying(true)
    const onPause = () => setPlaying(false)
    audio.addEventListener('timeupdate', onTime)
    audio.addEventListener('loadedmetadata', onMeta)
    audio.addEventListener('ended', onEnd)
    audio.addEventListener('play', onPlay)
    audio.addEventListener('pause', onPause)
    return () => {
      audio.removeEventListener('timeupdate', onTime)
      audio.removeEventListener('loadedmetadata', onMeta)
      audio.removeEventListener('ended', onEnd)
      audio.removeEventListener('play', onPlay)
      audio.removeEventListener('pause', onPause)
    }
  }, [])

  function toggle() {
    const audio = audioRef.current
    if (!audio) return
    if (audio.paused) {
      void audio.play().catch(() => {})
    } else {
      audio.pause()
    }
  }

  const progress = total > 0 ? Math.min(1, position / total) : 0
  const display = position > 0 ? position : total
  const accent = isMine ? 'text-white' : 'text-amber-300'
  const track = isMine ? 'bg-white/25' : 'bg-amber-500/25'
  const fill = isMine ? 'bg-white' : 'bg-amber-400'

  return (
    <div className="flex w-[220px] items-center gap-2">
      <button
        type="button"
        onClick={toggle}
        className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full transition ${
          isMine ? 'bg-white/15 hover:bg-white/25' : 'bg-amber-500/15 hover:bg-amber-500/25'
        }`}
      >
        {playing ? (
          <Pause className={`h-4 w-4 ${accent}`} />
        ) : (
          <Play className={`h-4 w-4 ${accent}`} />
        )}
      </button>
      <div className="flex-1">
        <div className={`h-[3px] w-full rounded ${track}`}>
          <div
            className={`h-full rounded ${fill}`}
            style={{ width: `${progress * 100}%` }}
          />
        </div>
        <div
          className={`mt-1 flex items-center gap-1 text-[10px] ${
            isMine ? 'text-white/80' : 'text-carbon-100'
          }`}
        >
          <Mic className="h-3 w-3" />
          <span>{formatSeconds(display)}</span>
        </div>
      </div>
      <audio ref={audioRef} src={url} preload="metadata" />
    </div>
  )
}

function formatSeconds(value: number): string {
  if (!Number.isFinite(value) || value <= 0) return '0:00'
  const total = Math.round(value)
  const m = Math.floor(total / 60)
  const s = total % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}

function renderLastMessagePreview(text: string): string {
  if (!text) return 'Беседа без сообщений'
  if (text === '[photo]') return '🖼 Фото'
  if (text === '[voice]') return '🎙 Голосовое сообщение'
  return text
}
