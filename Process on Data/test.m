function test(userBatSeq)

for i=1:size(userBatSeq, 1) - 1
   if(userBatSeq(i, 7) == userBatSeq(i + 1, 7))
      if(userBatSeq(i, 7) == 1)
         if(userBatSeq(i, 6) <= userBatSeq(i + 1, 6))
            
         else
             fprintf('c = 1, charge down\n');
         end
         
      else
          if(userBatSeq(i, 6) >= userBatSeq(i + 1, 6))
            
         else
             fprintf('c = 1, charge up\n');
         end
      end
   end
end

end