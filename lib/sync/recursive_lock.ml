module type S = sig
  type ('a, 'b) reagent
  type t

  val create : unit -> t
  val acq : t -> (unit, unit) reagent
  val try_acq : t -> (unit, bool) reagent
  val rel : t -> (unit, bool) reagent
end

module Make
    (Base : Base.S) (Tid : sig
      val get_tid : unit -> int
    end) : S with type ('a, 'b) reagent = ('a, 'b) Base.t = struct
  type ('a, 'b) reagent = ('a, 'b) Base.t

  open Base

  type thread_id = int
  type count = int

  (** A recursive lock is either recursively locked [count] times by [thread_id] or unlocked *)
  type status = Locked of thread_id * count | Unlocked

  type t = status Ref.ref

  let create () = Ref.mk_ref Unlocked

  let acq r =
    Ref.upd r (fun s () ->
        let tid = Tid.get_tid () in
        match s with
        | Unlocked ->
            (* No current owner, take the lock *)
            Some (Locked (tid, 1), ())
        | Locked (owner, count) ->
            if owner = tid then Some (Locked (tid, count + 1), ()) else None)

  let rel r =
    Ref.upd r (fun s () ->
        let tid = Tid.get_tid () in
        match s with
        | Unlocked -> Some (Unlocked, false)
        | Locked (owner, count) ->
            if owner = tid then
              let new_count = count - 1 in
              if new_count = 0 then Some (Unlocked, true)
              else Some (Locked (tid, new_count), true)
            else Some (Locked (owner, count), false))

  let try_acq r =
    Ref.upd r (fun s () ->
        let tid = Tid.get_tid () in
        match s with
        | Unlocked -> Some (Locked (tid, 1), true)
        | Locked (owner, count) ->
            if owner = tid then
              (* Already the owner, increase lock count *)
              Some (Locked (tid, count + 1), true)
            else
              (* Not the owner, don't wait on lock *)
              Some (Locked (owner, count), false))
end
