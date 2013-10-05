.class public Lde/aisec/Tracker;
.super Ljava/lang/Object;
.source "Tracker.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static track([Ljava/lang/Object;)[Ljava/lang/Object;
    .registers 6

    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v2, "TRACKING "

    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->print(Ljava/lang/String;)V

    array-length v2, p0

    const/4 v1, 0x0

    :goto_9
    if-lt v1, v2, :cond_13

    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v2, "\n"

    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->print(Ljava/lang/String;)V

    return-object p0

    :cond_13
    aget-object v0, p0, v1

    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    invoke-virtual {v3, v0}, Ljava/io/PrintStream;->print(Ljava/lang/Object;)V

    sget-object v3, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v4, ", "

    invoke-virtual {v3, v4}, Ljava/io/PrintStream;->print(Ljava/lang/String;)V

    add-int/lit8 v1, v1, 0x1

    goto :goto_9
.end method
