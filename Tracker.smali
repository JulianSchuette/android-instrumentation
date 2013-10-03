.class public Lde/aisec/utils/Tracker;
.super Landroid/app/Application;
.source "Tracker.java"


# static fields
.field private static final STACKS:Ljava/util/Hashtable; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Hashtable",
            "<",
            "Ljava/lang/Long;",
            "Ljava/util/Stack",
            "<",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation
.end field

.field private static final TAG:Ljava/lang/String; = "TRACKER"

.field private static final TRACKING_TABLE:Ljava/util/Hashtable;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Hashtable",
            "<",
            "Ljava/lang/String;",
            "Lde/aisec/utils/Register;",
            ">;"
        }
    .end annotation
.end field

.field private static instance:Lde/aisec/utils/Tracker;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .prologue
    .line 14
    new-instance v0, Ljava/util/Hashtable;

    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    sput-object v0, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    .line 15
    new-instance v0, Ljava/util/Hashtable;

    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    sput-object v0, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    .line 17
    return-void
.end method

.method public constructor <init>()V
    .registers 1

    .prologue
    .line 13
    invoke-direct {p0}, Landroid/app/Application;-><init>()V

    return-void
.end method

.method private static dump()V
    .registers 6

    .prologue
    .line 30
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v4, "----- Tainted Variables (Tracking Table) -------"

    invoke-virtual {v3, v4}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 31
    sget-object v3, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    invoke-virtual {v3}, Ljava/util/Hashtable;->keySet()Ljava/util/Set;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v3

    .local v0, key:Ljava/lang/String;
    .local v1, reg:Lde/aisec/utils/Register;
    .local v2, sb:Ljava/lang/StringBuffer;
    :goto_11
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-nez v4, :cond_1f

    .line 42
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v4, "----------------------------"

    invoke-virtual {v3, v4}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 43
    return-void

    .line 31
    :cond_1f
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    .end local v0           #key:Ljava/lang/String;
    check-cast v0, Ljava/lang/String;

    .line 32
    .restart local v0       #key:Ljava/lang/String;
    new-instance v2, Ljava/lang/StringBuffer;

    .end local v1           #reg:Lde/aisec/utils/Register;
    .end local v2           #sb:Ljava/lang/StringBuffer;
    invoke-direct {v2}, Ljava/lang/StringBuffer;-><init>()V

    .line 33
    .restart local v2       #sb:Ljava/lang/StringBuffer;
    const-string v4, "| "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 34
    invoke-virtual {v2, v0}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 35
    const-string v4, " : "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 36
    sget-object v4, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    invoke-virtual {v4, v0}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lde/aisec/utils/Register;

    .line 37
    .restart local v1       #reg:Lde/aisec/utils/Register;
    iget-object v4, v1, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    invoke-virtual {v2, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 38
    const-string v4, "-"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 39
    iget-object v4, v1, Lde/aisec/utils/Register;->value:Ljava/lang/Object;

    invoke-virtual {v2, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/Object;)Ljava/lang/StringBuffer;

    .line 40
    sget-object v4, Ljava/lang/System;->out:Ljava/io/PrintStream;

    invoke-virtual {v2}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    goto :goto_11
.end method

.method private static getUniqueName(Lde/aisec/utils/Register;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    .registers 8
    .parameter "reg"
    .parameter "clazz"
    .parameter "method"
    .parameter "instance"

    .prologue
    .line 46
    new-instance v0, Ljava/lang/StringBuffer;

    invoke-direct {v0}, Ljava/lang/StringBuffer;-><init>()V

    .line 48
    .local v0, sb:Ljava/lang/StringBuffer;
    iget-object v2, p0, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    const-string v3, "."

    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v2

    if-nez v2, :cond_28

    .line 49
    invoke-virtual {p3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 50
    invoke-virtual {v0, p2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 54
    :goto_19
    const-string v2, "_"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 55
    iget-object v2, p0, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    invoke-virtual {v0, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 56
    invoke-virtual {v0}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v1

    .line 57
    .local v1, uniqueName:Ljava/lang/String;
    return-object v1

    .line 52
    .end local v1           #uniqueName:Ljava/lang/String;
    :cond_28
    invoke-virtual {v0, p2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto :goto_19
.end method

.method public static declared-synchronized pop(Ljava/lang/Object;Ljava/lang/String;)V
    .registers 9
    .parameter "instance"
    .parameter "methodName"

    .prologue
    .line 215
    const-class v4, Lde/aisec/utils/Tracker;

    monitor-enter v4

    :try_start_3
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Thread;->getId()J

    move-result-wide v1

    .line 216
    .local v1, threadID:J
    sget-object v3, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    if-eqz v3, :cond_73

    .line 217
    sget-object v3, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Stack;

    invoke-virtual {v3}, Ljava/util/Stack;->size()I

    move-result v3

    if-lez v3, :cond_5b

    .line 218
    sget-object v3, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Stack;

    invoke-virtual {v3}, Ljava/util/Stack;->pop()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 219
    .local v0, methodIdentifier:Ljava/lang/String;
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "POPPING FROM STACK of thread "

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, ": "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_59
    .catchall {:try_start_3 .. :try_end_59} :catchall_70

    .line 226
    .end local v0           #methodIdentifier:Ljava/lang/String;
    :goto_59
    monitor-exit v4

    return-void

    .line 221
    :cond_5b
    :try_start_5b
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "WARN: UNEXPECTED! Nothing to pop from stack for thread "

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_6f
    .catchall {:try_start_5b .. :try_end_6f} :catchall_70

    goto :goto_59

    .line 215
    .end local v1           #threadID:J
    :catchall_70
    move-exception v3

    monitor-exit v4

    throw v3

    .line 224
    .restart local v1       #threadID:J
    :cond_73
    :try_start_73
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "WARN: Could not pop, thread id not in stack: "

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_87
    .catchall {:try_start_73 .. :try_end_87} :catchall_70

    goto :goto_59
.end method

.method public static declared-synchronized propagate(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    .registers 10
    .parameter "line"
    .parameter "instance"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"

    .prologue
    .line 161
    const-class v2, Lde/aisec/utils/Tracker;

    monitor-enter v2

    if-eqz p4, :cond_9

    :try_start_5
    array-length v1, p4

    const/4 v3, 0x2

    if-ge v1, v3, :cond_10

    .line 162
    :cond_9
    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v3, "ERROR IN PROPAGATE: Did not receive correct parameter amount (>=2)"

    invoke-virtual {v1, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 163
    :cond_10
    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "Propagating from "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    const/4 v4, 0x1

    aget-object v4, p4, v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, " to "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const/4 v4, 0x0

    aget-object v4, p4, v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 165
    sget-object v1, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    const/4 v3, 0x1

    aget-object v3, p4, v3

    invoke-virtual {v1, v3}, Ljava/util/Hashtable;->contains(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_4e

    .line 166
    const/4 v1, 0x0

    aget-object v1, p4, v1

    invoke-static {v1, p2, p3, p1}, Lde/aisec/utils/Tracker;->getUniqueName(Lde/aisec/utils/Register;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 167
    .local v0, uniqueName:Ljava/lang/String;
    sget-object v1, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    const/4 v3, 0x0

    aget-object v3, p4, v3

    invoke-virtual {v1, v0, v3}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_4e
    .catchall {:try_start_5 .. :try_end_4e} :catchall_50

    .line 169
    .end local v0           #uniqueName:Ljava/lang/String;
    :cond_4e
    monitor-exit v2

    return-void

    .line 161
    :catchall_50
    move-exception v1

    monitor-exit v2

    throw v1
.end method

.method public static declared-synchronized propagateInstanceVar(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    .registers 6
    .parameter "line"
    .parameter "instance"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"

    .prologue
    .line 178
    const-class v0, Lde/aisec/utils/Tracker;

    monitor-enter v0

    monitor-exit v0

    return-void
.end method

.method public static declared-synchronized push(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/String;)V
    .registers 10
    .parameter "instance"
    .parameter "methodName"
    .parameter "callString"

    .prologue
    .line 205
    const-class v4, Lde/aisec/utils/Tracker;

    monitor-enter v4

    :try_start_3
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Thread;->getId()J

    move-result-wide v1

    .line 206
    .local v1, threadID:J
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-direct {v3, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, "_"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 207
    .local v0, methodIdentifier:Ljava/lang/String;
    sget-object v3, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    if-nez v3, :cond_44

    .line 208
    sget-object v3, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    new-instance v6, Ljava/util/Stack;

    invoke-direct {v6}, Ljava/util/Stack;-><init>()V

    invoke-virtual {v3, v5, v6}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 210
    :cond_44
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "PUSHING ON STACK of thread "

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, ": "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, " with callstring "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 211
    sget-object v3, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Stack;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v6

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    const-string v6, "|"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/util/Stack;->push(Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_92
    .catchall {:try_start_3 .. :try_end_92} :catchall_94

    .line 212
    monitor-exit v4

    return-void

    .line 205
    .end local v0           #methodIdentifier:Ljava/lang/String;
    .end local v1           #threadID:J
    :catchall_94
    move-exception v3

    monitor-exit v4

    throw v3
.end method

.method public static declared-synchronized track(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    .registers 14
    .parameter "line"
    .parameter "instance"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"

    .prologue
    .line 86
    const-class v4, Lde/aisec/utils/Tracker;

    monitor-enter v4

    if-nez p1, :cond_1c

    .line 87
    :try_start_5
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-direct {v3, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, "STATIC"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    :try_end_1b
    .catchall {:try_start_5 .. :try_end_1b} :catchall_86

    move-result-object p1

    .line 89
    .end local p1
    :cond_1c
    :try_start_1c
    array-length v5, p4
    :try_end_1d
    .catchall {:try_start_1c .. :try_end_1d} :catchall_86
    .catch Ljava/lang/NullPointerException; {:try_start_1c .. :try_end_1d} :catch_69

    const/4 v3, 0x0

    :goto_1e
    if-lt v3, v5, :cond_22

    .line 99
    :goto_20
    monitor-exit v4

    return-void

    .line 89
    :cond_22
    :try_start_22
    aget-object v1, p4, v3

    .line 90
    .local v1, reg:Lde/aisec/utils/Register;
    invoke-static {v1, p2, p3, p1}, Lde/aisec/utils/Tracker;->getUniqueName(Lde/aisec/utils/Register;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    .line 91
    .local v2, uniqueName:Ljava/lang/String;
    const-string v6, "TRACKER"

    new-instance v7, Ljava/lang/StringBuilder;

    const-string v8, "I am tracking "

    invoke-direct {v7, v8}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ", line "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, " values: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, v1, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ":"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, v1, Lde/aisec/utils/Register;->value:Ljava/lang/Object;

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 92
    sget-object v6, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    invoke-virtual {v6, v2, v1}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 93
    invoke-static {}, Lde/aisec/utils/Tracker;->dump()V
    :try_end_66
    .catchall {:try_start_22 .. :try_end_66} :catchall_86
    .catch Ljava/lang/NullPointerException; {:try_start_22 .. :try_end_66} :catch_69

    .line 89
    add-int/lit8 v3, v3, 0x1

    goto :goto_1e

    .line 95
    .end local v1           #reg:Lde/aisec/utils/Register;
    .end local v2           #uniqueName:Ljava/lang/String;
    :catch_69
    move-exception v0

    .line 96
    .local v0, npe:Ljava/lang/NullPointerException;
    :try_start_6a
    invoke-virtual {v0}, Ljava/lang/NullPointerException;->printStackTrace()V

    .line 97
    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "WEIRD! GOT REGISTER WITHOUT NAME: "

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_85
    .catchall {:try_start_6a .. :try_end_85} :catchall_86

    goto :goto_20

    .line 86
    .end local v0           #npe:Ljava/lang/NullPointerException;
    :catchall_86
    move-exception v3

    monitor-exit v4

    throw v3
.end method

.method public static declared-synchronized track(ILjava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    .registers 6
    .parameter "line"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"

    .prologue
    .line 20
    const-class v0, Lde/aisec/utils/Tracker;

    monitor-enter v0

    const/4 v1, 0x0

    :try_start_4
    invoke-static {p0, v1, p1, p2, p3}, Lde/aisec/utils/Tracker;->track(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    :try_end_7
    .catchall {:try_start_4 .. :try_end_7} :catchall_9

    .line 21
    monitor-exit v0

    return-void

    .line 20
    :catchall_9
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized trackIfTracked(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;I)V
    .registers 32
    .parameter "line"
    .parameter "instance"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"
    .parameter "regCount"

    .prologue
    .line 102
    const-class v21, Lde/aisec/utils/Tracker;

    monitor-enter v21

    if-nez p1, :cond_28

    .line 103
    :try_start_5
    new-instance v20, Ljava/lang/StringBuilder;

    invoke-static/range {p2 .. p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v22

    move-object/from16 v0, v20

    move-object/from16 v1, v22

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    move-object/from16 v0, v20

    move-object/from16 v1, p3

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    const-string v22, "STATIC"

    move-object/from16 v0, v20

    move-object/from16 v1, v22

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual/range {v20 .. v20}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    :try_end_27
    .catchall {:try_start_5 .. :try_end_27} :catchall_1f3

    move-result-object p1

    .line 105
    .end local p1
    :cond_28
    :try_start_28
    sget-object v20, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v22, "IN trackIfTracked"

    move-object/from16 v0, v20

    move-object/from16 v1, v22

    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 107
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v20

    invoke-virtual/range {v20 .. v20}, Ljava/lang/Thread;->getId()J

    move-result-wide v18

    .line 110
    .local v18, threadID:J
    move-object/from16 v0, p4

    array-length v0, v0

    move/from16 v22, v0
    :try_end_40
    .catchall {:try_start_28 .. :try_end_40} :catchall_1f3
    .catch Ljava/lang/NullPointerException; {:try_start_28 .. :try_end_40} :catch_1d1

    const/16 v20, 0x0

    :goto_42
    move/from16 v0, v20

    move/from16 v1, v22

    if-lt v0, v1, :cond_4a

    .line 158
    .end local v18           #threadID:J
    :goto_48
    monitor-exit v21

    return-void

    .line 110
    .restart local v18       #threadID:J
    :cond_4a
    :try_start_4a
    aget-object v12, p4, v20

    .line 117
    .local v12, reg:Lde/aisec/utils/Register;
    sget-object v23, Lde/aisec/utils/Tracker;->STACKS:Ljava/util/Hashtable;

    invoke-static/range {v18 .. v19}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v15

    check-cast v15, Ljava/util/Stack;

    .line 118
    .local v15, stack:Ljava/util/Stack;
    invoke-virtual {v15}, Ljava/util/Stack;->size()I

    move-result v23

    add-int/lit8 v23, v23, -0x1

    move/from16 v0, v23

    invoke-virtual {v15, v0}, Ljava/util/Stack;->get(I)Ljava/lang/Object;

    move-result-object v17

    check-cast v17, Ljava/lang/String;

    .line 119
    .local v17, stckTopEntry:Ljava/lang/String;
    const-string v23, "\\|"

    move-object/from16 v0, v17

    move-object/from16 v1, v23

    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v16

    .line 120
    .local v16, stckTop:[Ljava/lang/String;
    const/16 v23, 0x0

    aget-object v5, v16, v23

    .line 121
    .local v5, caller:Ljava/lang/String;
    const/16 v23, 0x1

    aget-object v9, v16, v23

    .line 123
    .local v9, invocationString:Ljava/lang/String;
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v24, Ljava/lang/StringBuilder;

    const-string v25, "  Invocation String is "

    invoke-direct/range {v24 .. v25}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    move-object/from16 v0, v24

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v24

    invoke-virtual/range {v24 .. v24}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 124
    const-string v23, "invoke-range"

    move-object/from16 v0, v23

    invoke-virtual {v9, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v23

    if-nez v23, :cond_1c5

    .line 126
    const-string v23, "invoke-"

    move-object/from16 v0, v23

    invoke-virtual {v9, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v23

    if-eqz v23, :cond_1f6

    .line 128
    const-string v23, "{"

    move-object/from16 v0, v23

    invoke-virtual {v9, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v23

    add-int/lit8 v23, v23, 0x1

    const-string v24, "}"

    move-object/from16 v0, v24

    invoke-virtual {v9, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v24

    move/from16 v0, v23

    move/from16 v1, v24

    invoke-virtual {v9, v0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v3

    .line 129
    .local v3, args:Ljava/lang/String;
    iget-object v0, v12, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    move-object/from16 v23, v0

    const/16 v24, 0x1

    invoke-virtual/range {v23 .. v24}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v23

    invoke-static/range {v23 .. v23}, Ljava/lang/Integer;->valueOf(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v23

    invoke-virtual/range {v23 .. v23}, Ljava/lang/Integer;->intValue()I

    move-result v23

    add-int/lit8 v13, v23, -0x1

    .line 130
    .local v13, regPosition:I
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v24, Ljava/lang/StringBuilder;

    const-string v25, "  I will check for argument at position "

    invoke-direct/range {v24 .. v25}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    move-object/from16 v0, v24

    invoke-virtual {v0, v13}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v24

    invoke-virtual/range {v24 .. v24}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 131
    const-string v23, ","

    move-object/from16 v0, v23

    invoke-virtual {v3, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v23

    aget-object v4, v23, v13

    .line 132
    .local v4, argument:Ljava/lang/String;
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v24, Ljava/lang/StringBuilder;

    const-string v25, "  This would be argument "

    invoke-direct/range {v24 .. v25}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v25

    invoke-virtual/range {v24 .. v25}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v24

    invoke-virtual/range {v24 .. v24}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 135
    const-string v23, "L"

    move-object/from16 v0, v23

    invoke-virtual {v5, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v23

    add-int/lit8 v23, v23, 0x1

    const-string v24, ";"

    move-object/from16 v0, v24

    invoke-virtual {v5, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v24

    move/from16 v0, v23

    move/from16 v1, v24

    invoke-virtual {v5, v0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v23

    const-string v24, "/"

    const-string v25, "."

    invoke-virtual/range {v23 .. v25}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v6

    .line 136
    .local v6, caller_clazz:Ljava/lang/String;
    const-string v23, " "

    move-object/from16 v0, v23

    invoke-virtual {v5, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v23

    const-string v24, "("

    move-object/from16 v0, v24

    invoke-virtual {v5, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v24

    move/from16 v0, v23

    move/from16 v1, v24

    invoke-virtual {v5, v0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v23

    invoke-virtual/range {v23 .. v23}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v8

    .line 137
    .local v8, caller_method:Ljava/lang/String;
    new-instance v23, Ljava/lang/StringBuilder;

    invoke-static {v6}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v24

    invoke-direct/range {v23 .. v24}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    const-string v24, "."

    invoke-virtual/range {v23 .. v24}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v23

    move-object/from16 v0, v23

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v23

    const-string v24, "@"

    move-object/from16 v0, v24

    invoke-virtual {v5, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v24

    const-string v25, "_"

    move-object/from16 v0, v25

    invoke-virtual {v5, v0}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I

    move-result v25

    move/from16 v0, v24

    move/from16 v1, v25

    invoke-virtual {v5, v0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v23

    invoke-virtual/range {v23 .. v23}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    .line 138
    .local v7, caller_instance:Ljava/lang/String;
    new-instance v23, Lde/aisec/utils/Register;

    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v24

    invoke-direct/range {v23 .. v24}, Lde/aisec/utils/Register;-><init>(Ljava/lang/String;)V

    move-object/from16 v0, v23

    invoke-static {v0, v6, v8, v7}, Lde/aisec/utils/Tracker;->getUniqueName(Lde/aisec/utils/Register;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v14

    .line 139
    .local v14, register_unique:Ljava/lang/String;
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v24, Ljava/lang/StringBuilder;

    const-string v25, "   Unique register name: "

    invoke-direct/range {v24 .. v25}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    move-object/from16 v0, v24

    invoke-virtual {v0, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v24

    invoke-virtual/range {v24 .. v24}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 142
    sget-object v23, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    move-object/from16 v0, v23

    invoke-virtual {v0, v14}, Ljava/util/Hashtable;->containsKey(Ljava/lang/Object;)Z

    move-result v23

    if-eqz v23, :cond_1c9

    .line 143
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v24, "  IS TAINTED!"

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 144
    move-object/from16 v0, p2

    move-object/from16 v1, p3

    move-object/from16 v2, p1

    invoke-static {v12, v0, v1, v2}, Lde/aisec/utils/Tracker;->getUniqueName(Lde/aisec/utils/Register;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v10

    .line 145
    .local v10, markIt:Ljava/lang/String;
    sget-object v23, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    move-object/from16 v0, v23

    invoke-virtual {v0, v10, v12}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 146
    invoke-static {}, Lde/aisec/utils/Tracker;->dump()V

    .line 110
    .end local v3           #args:Ljava/lang/String;
    .end local v4           #argument:Ljava/lang/String;
    .end local v6           #caller_clazz:Ljava/lang/String;
    .end local v7           #caller_instance:Ljava/lang/String;
    .end local v8           #caller_method:Ljava/lang/String;
    .end local v10           #markIt:Ljava/lang/String;
    .end local v13           #regPosition:I
    .end local v14           #register_unique:Ljava/lang/String;
    :cond_1c5
    :goto_1c5
    add-int/lit8 v20, v20, 0x1

    goto/16 :goto_42

    .line 148
    .restart local v3       #args:Ljava/lang/String;
    .restart local v4       #argument:Ljava/lang/String;
    .restart local v6       #caller_clazz:Ljava/lang/String;
    .restart local v7       #caller_instance:Ljava/lang/String;
    .restart local v8       #caller_method:Ljava/lang/String;
    .restart local v13       #regPosition:I
    .restart local v14       #register_unique:Ljava/lang/String;
    :cond_1c9
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v24, "  param was not tainted."

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_1d0
    .catchall {:try_start_4a .. :try_end_1d0} :catchall_1f3
    .catch Ljava/lang/NullPointerException; {:try_start_4a .. :try_end_1d0} :catch_1d1

    goto :goto_1c5

    .line 154
    .end local v3           #args:Ljava/lang/String;
    .end local v4           #argument:Ljava/lang/String;
    .end local v5           #caller:Ljava/lang/String;
    .end local v6           #caller_clazz:Ljava/lang/String;
    .end local v7           #caller_instance:Ljava/lang/String;
    .end local v8           #caller_method:Ljava/lang/String;
    .end local v9           #invocationString:Ljava/lang/String;
    .end local v12           #reg:Lde/aisec/utils/Register;
    .end local v13           #regPosition:I
    .end local v14           #register_unique:Ljava/lang/String;
    .end local v15           #stack:Ljava/util/Stack;
    .end local v16           #stckTop:[Ljava/lang/String;
    .end local v17           #stckTopEntry:Ljava/lang/String;
    .end local v18           #threadID:J
    :catch_1d1
    move-exception v11

    .line 155
    .local v11, npe:Ljava/lang/NullPointerException;
    :try_start_1d2
    invoke-virtual {v11}, Ljava/lang/NullPointerException;->printStackTrace()V

    .line 156
    sget-object v20, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v22, Ljava/lang/StringBuilder;

    const-string v23, "WEIRD! GOT REGISTER WITHOUT NAME: "

    invoke-direct/range {v22 .. v23}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual/range {p4 .. p4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v23

    invoke-virtual/range {v22 .. v23}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v22

    invoke-virtual/range {v22 .. v22}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v22

    move-object/from16 v0, v20

    move-object/from16 v1, v22

    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_1f1
    .catchall {:try_start_1d2 .. :try_end_1f1} :catchall_1f3

    goto/16 :goto_48

    .line 102
    .end local v11           #npe:Ljava/lang/NullPointerException;
    :catchall_1f3
    move-exception v20

    monitor-exit v21

    throw v20

    .line 151
    .restart local v5       #caller:Ljava/lang/String;
    .restart local v9       #invocationString:Ljava/lang/String;
    .restart local v12       #reg:Lde/aisec/utils/Register;
    .restart local v15       #stack:Ljava/util/Stack;
    .restart local v16       #stckTop:[Ljava/lang/String;
    .restart local v17       #stckTopEntry:Ljava/lang/String;
    .restart local v18       #threadID:J
    :cond_1f6
    :try_start_1f6
    sget-object v23, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v24, Ljava/lang/StringBuilder;

    const-string v25, "UNEXPECTED VALUE ON STACK: "

    invoke-direct/range {v24 .. v25}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    move-object/from16 v0, v24

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v24

    invoke-virtual/range {v24 .. v24}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v24

    invoke-virtual/range {v23 .. v24}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_20c
    .catchall {:try_start_1f6 .. :try_end_20c} :catchall_1f3
    .catch Ljava/lang/NullPointerException; {:try_start_1f6 .. :try_end_20c} :catch_1d1

    goto :goto_1c5
.end method

.method public static declared-synchronized untrack(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    .registers 14
    .parameter "line"
    .parameter "instance"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"

    .prologue
    .line 185
    const-class v4, Lde/aisec/utils/Tracker;

    monitor-enter v4

    if-nez p1, :cond_1c

    .line 186
    :try_start_5
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-direct {v3, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, "STATIC"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    :try_end_1b
    .catchall {:try_start_5 .. :try_end_1b} :catchall_7e

    move-result-object p1

    .line 188
    .end local p1
    :cond_1c
    :try_start_1c
    array-length v5, p4
    :try_end_1d
    .catchall {:try_start_1c .. :try_end_1d} :catchall_7e
    .catch Ljava/lang/NullPointerException; {:try_start_1c .. :try_end_1d} :catch_79

    const/4 v3, 0x0

    :goto_1e
    if-lt v3, v5, :cond_22

    .line 196
    :goto_20
    monitor-exit v4

    return-void

    .line 188
    :cond_22
    :try_start_22
    aget-object v1, p4, v3

    .line 189
    .local v1, reg:Lde/aisec/utils/Register;
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v7}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v7

    invoke-direct {v6, v7}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v7, v1, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    .line 190
    .local v2, uniqueName:Ljava/lang/String;
    const-string v6, "TRACKER"

    new-instance v7, Ljava/lang/StringBuilder;

    const-string v8, "I am untracking "

    invoke-direct {v7, v8}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ", line "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, " values: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, v1, Lde/aisec/utils/Register;->name:Ljava/lang/String;

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ":"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, v1, Lde/aisec/utils/Register;->value:Ljava/lang/Object;

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 191
    sget-object v6, Lde/aisec/utils/Tracker;->TRACKING_TABLE:Ljava/util/Hashtable;

    invoke-virtual {v6, v2}, Ljava/util/Hashtable;->remove(Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_76
    .catchall {:try_start_22 .. :try_end_76} :catchall_7e
    .catch Ljava/lang/NullPointerException; {:try_start_22 .. :try_end_76} :catch_79

    .line 188
    add-int/lit8 v3, v3, 0x1

    goto :goto_1e

    .line 193
    .end local v1           #reg:Lde/aisec/utils/Register;
    .end local v2           #uniqueName:Ljava/lang/String;
    :catch_79
    move-exception v0

    .line 194
    .local v0, npe:Ljava/lang/NullPointerException;
    :try_start_7a
    invoke-virtual {v0}, Ljava/lang/NullPointerException;->printStackTrace()V
    :try_end_7d
    .catchall {:try_start_7a .. :try_end_7d} :catchall_7e

    goto :goto_20

    .line 185
    .end local v0           #npe:Ljava/lang/NullPointerException;
    :catchall_7e
    move-exception v3

    monitor-exit v4

    throw v3
.end method

.method public static declared-synchronized untrack(ILjava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    .registers 6
    .parameter "line"
    .parameter "clazz"
    .parameter "method"
    .parameter "regs"

    .prologue
    .line 181
    const-class v0, Lde/aisec/utils/Tracker;

    monitor-enter v0

    const/4 v1, 0x0

    :try_start_4
    invoke-static {p0, v1, p1, p2, p3}, Lde/aisec/utils/Tracker;->untrack(ILjava/lang/Object;Ljava/lang/String;Ljava/lang/String;[Lde/aisec/utils/Register;)V
    :try_end_7
    .catchall {:try_start_4 .. :try_end_7} :catchall_9

    .line 182
    monitor-exit v0

    return-void

    .line 181
    :catchall_9
    move-exception v1

    monitor-exit v0

    throw v1
.end method


# virtual methods
.method public onCreate()V
    .registers 1

    .prologue
    .line 25
    invoke-super {p0}, Landroid/app/Application;->onCreate()V

    .line 26
    sput-object p0, Lde/aisec/utils/Tracker;->instance:Lde/aisec/utils/Tracker;

    .line 27
    return-void
.end method

.method public declared-synchronized warn()V
    .registers 6

    .prologue
    .line 61
    monitor-enter p0

    :try_start_1
    sget-object v2, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "Instance: "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 62
    sget-object v2, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "Context: "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0}, Lde/aisec/utils/Tracker;->getApplicationContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 68
    new-instance v0, Landroid/app/Notification;

    invoke-direct {v0}, Landroid/app/Notification;-><init>()V

    .line 69
    .local v0, noti:Landroid/app/Notification;
    const-string v2, "New mail from test@gmail.com"

    iput-object v2, v0, Landroid/app/Notification;->tickerText:Ljava/lang/CharSequence;

    .line 70
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    iput-wide v2, v0, Landroid/app/Notification;->when:J

    .line 75
    const-string v2, "notification"

    invoke-virtual {p0, v2}, Lde/aisec/utils/Tracker;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/app/NotificationManager;

    .line 78
    .local v1, notificationManager:Landroid/app/NotificationManager;
    iget v2, v0, Landroid/app/Notification;->flags:I

    or-int/lit8 v2, v2, 0x10

    iput v2, v0, Landroid/app/Notification;->flags:I

    .line 80
    const/4 v2, 0x0

    invoke-virtual {v1, v2, v0}, Landroid/app/NotificationManager;->notify(ILandroid/app/Notification;)V
    :try_end_4e
    .catchall {:try_start_1 .. :try_end_4e} :catchall_50

    .line 81
    monitor-exit p0

    return-void

    .line 61
    .end local v0           #noti:Landroid/app/Notification;
    .end local v1           #notificationManager:Landroid/app/NotificationManager;
    :catchall_50
    move-exception v2

    monitor-exit p0

    throw v2
.end method
