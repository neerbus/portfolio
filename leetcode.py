# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseKGroup(self, head: Optional[ListNode], k: int) -> Optional[ListNode]:
        megaprev = None
        megahead = None
        lister = []
        index = 0
        while head:
            lister.append(head)
            head = head.next
            index += 1
            if index == k:
                prev = None
                for num in lister[len(lister)-1-index::-1]:
                    if not prev:
                        if not megahead:
                            megahead = num
                        if megaprev:
                            megaprev.next = num
                        prev = num
                        index -= 1
                        continue
                    prev.next = num
                    num.next = None
                    prev = num
                    index -= 1
                    if index == 0:
                        megaprev = num
                lister = []
        if index > 0:
            megaprev.next = lister[len(lister)-index]
        return megahead
